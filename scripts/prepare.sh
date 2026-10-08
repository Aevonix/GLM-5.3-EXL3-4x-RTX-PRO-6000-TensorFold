#!/usr/bin/env bash
# Build the pinned image and download the pinned weights once. Also sourced by start.sh and stop.sh.
# Usage: scripts/prepare.sh [--image|--label]; DRY_RUN=1 prints the plan without Docker, GPUs or file changes.
set -euo pipefail
# shellcheck source=scripts/config.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/config.sh"

log() { printf '%s\n' "$*"; }
fail() { printf '[%s] %s\n' "$1" "$2" >&2; exit 1; }
warn() { printf '[%s] %s\n' "$1" "$2" >&2; }
plan() { printf '  '; printf '%q ' "$@"; printf '\n'; }
run() { if [[ "$DRY_RUN" == 1 ]]; then plan "$@"; else "$@"; fi; }

validate_config() {
  local key path value cp parallel context drafter
  [[ "$DRY_RUN" =~ ^[01]$ ]] || fail E_CONFIG 'DRY_RUN must be 0 or 1.'
  [[ -f "$PROFILE" ]] || fail E_CONFIG "Profile not found: $PROFILE"
  while IFS='=' read -r key value; do
    [[ -z "$key" || "$key" == \#* ]] && continue
    [[ "$key" =~ ^[A-Z][A-Z0-9_]*$ && -n "$value" ]] || fail E_CONFIG "Invalid profile entry in $PROFILE: $key"
  done < "$PROFILE"
  for key in PORT MASTER_PORT MAX_TOKENS LOG_KEEP WAIT_TIMEOUT SMOKE_TIMEOUT STOP_TIMEOUT MIN_GPU_FREE_MIB MODEL_FREE_GIB DSPARK_FREE_GIB IMAGE_FREE_GIB CACHE_FREE_GIB; do
    [[ "${!key}" =~ ^[1-9][0-9]*$ ]] || fail E_CONFIG "$key must be a positive integer."
  done
  (( PORT <= 65535 && MASTER_PORT <= 65535 && PORT != MASTER_PORT )) || fail E_CONFIG 'PORT and MASTER_PORT must be distinct ports in 1-65535.'
  cp=$(profile_value CP); parallel=$(profile_value PARALLEL); context=$(profile_value CONTEXT); drafter=$(profile_value DRAFTER)
  [[ "$cp" =~ ^[01]$ ]] || fail E_CONFIG 'CP must be 1 (context parallel) or 0 (standard tensor parallel).'
  [[ "$parallel" =~ ^[1-5]$ ]] || fail E_CONFIG 'PARALLEL must be 1-5 (five sessions require CP=1).'
  [[ "$cp" == 1 || "$parallel" -le 4 ]] || fail E_CONFIG 'CP=0 supports at most PARALLEL=4.'
  [[ "$context" =~ ^[1-9][0-9]*$ ]] && (( context <= 1048576 )) || fail E_CONFIG 'CONTEXT must be a positive integer of at most 1048576.'
  [[ "$(profile_value KV)" =~ ^(fp8|fp4)$ && "$(profile_value DENSE)" =~ ^(fp8|q4)$ ]] || fail E_CONFIG 'Use KV=fp8|fp4 and DENSE=fp8|q4; FP8/FP8 is the measured quality reference.'
  case "$drafter" in
    dspark) DRAFTER_DIR=$DSPARK_DIR ;;
    dflash2)
      [[ "$parallel" == 1 ]] || fail E_CONFIG 'DRAFTER=dflash2 requires PARALLEL=1.'
      [[ -n "$DFLASH2_DIR" ]] || fail E_CONFIG 'DRAFTER=dflash2 needs DFLASH2_DIR: download the DFlash2 weights yourself under their license.'
      DRAFTER_DIR=$DFLASH2_DIR ;;
    *) fail E_CONFIG 'DRAFTER must be dspark (default) or dflash2 (optional, user-supplied weights).' ;;
  esac
  [[ "$SERVED_NAME" =~ ^[A-Za-z0-9][A-Za-z0-9._:/-]*$ ]] || fail E_CONFIG 'SERVED_NAME contains unsupported characters.'
  [[ "$CONTAINER_PREFIX" =~ ^[a-zA-Z0-9][a-zA-Z0-9_.-]*$ ]] || fail E_CONFIG 'CONTAINER_PREFIX contains unsupported characters.'
  for key in DATA_DIR MODEL_DIR DSPARK_DIR DRAFTER_DIR CACHE_DIR STATE_DIR LOG_DIR PROFILE; do
    path=${!key}
    [[ "$path" == /* && "$path" != *:* && "$path" != *$'\n'* ]] || fail E_CONFIG "$key must be an absolute path without colons or newlines."
  done
  export DRAFTER_DIR
}

# The image is identified by the pinned upstream commit, the ordered patch manifests (which pin every patch's
# SHA256), the base Dockerfile and the applier. Any change produces a new label and a rebuild.
recipe_hash() {
  { printf '%s\n' "$ENGINE_COMMIT"
    cat "$REPO_ROOT/patches/series.json" "$REPO_ROOT/patches/recipe-series.json" \
        "$REPO_ROOT/build/recipe-base/Dockerfile" "$REPO_ROOT/scripts/apply-patches.sh"
  } | sha256sum | cut -c1-16
}
image_ready() { [[ "$(docker image inspect -f '{{index .Config.Labels "org.aevonix.recipe"}}' "$IMAGE" 2>/dev/null || true)" == "$(recipe_hash)" ]]; }
weights_ready() { [[ -f "$1/config.json" && -f "$1/.revision" && "$(cat "$1/.revision")" == "$2" ]]; }

check_platform() {
  local cmd
  [[ "$(uname -s)" == Linux && "$(uname -m)" == x86_64 ]] || fail E_PLATFORM 'This recipe requires Linux x86_64.'
  for cmd in docker git patch curl python3 flock setsid gzip tar sha256sum nvidia-smi; do
    command -v "$cmd" >/dev/null || fail E_DEPENDENCY "Missing command: $cmd. See README requirements."
  done
  docker info >/dev/null 2>&1 || fail E_DOCKER 'Cannot talk to Docker. Start the daemon and check socket permissions.'
  if (( EUID != 0 )) && ! id -nG | tr ' ' '\n' | grep -qx docker; then
    fail E_DOCKER_GROUP 'Your login is not in the docker group. Add it and start a new login session.'
  fi
  docker info --format '{{json .Runtimes}}' | python3 -c 'import json,sys; sys.exit(0 if "nvidia" in json.load(sys.stdin) else 1)' || fail E_NVIDIA_RUNTIME 'Docker has no NVIDIA runtime. Install and configure NVIDIA Container Toolkit.'
  log '[I_PLATFORM] Linux x86_64, Docker access and NVIDIA runtime are ready.'
}

check_gpus() {
  local gpu row name free used power count processes
  count=$(nvidia-smi --query-gpu=index --format=csv,noheader | wc -l) || fail E_GPU 'Cannot query GPUs. Check the NVIDIA driver.'
  (( count >= 4 )) || fail E_GPU "Found $count GPUs; this recipe runs four ranks on GPUs 0-3."
  for gpu in 0 1 2 3; do
    row=$(nvidia-smi -i "$gpu" --query-gpu=name,memory.free,memory.used,power.limit --format=csv,noheader,nounits) || fail E_GPU "Cannot query GPU $gpu."
    IFS=, read -r name free used power <<< "$row"
    free=${free//[[:space:]]/}; used=${used//[[:space:]]/}; power=${power//[[:space:]]/}
    [[ "$free" =~ ^[0-9]+$ && "$used" =~ ^[0-9]+$ ]] || fail E_GPU "GPU $gpu returned invalid memory information."
    [[ "$name" == *"RTX PRO 6000"* ]] || warn W_GPU_MODEL "GPU $gpu is${name}; this recipe was measured on RTX PRO 6000 Blackwell Max-Q GPUs."
    (( free >= MIN_GPU_FREE_MIB )) || fail E_GPU_MEMORY "GPU $gpu has $free MiB free; at least $MIN_GPU_FREE_MIB MiB is required. Stop other GPU workloads."
    (( used < 1000 )) || fail E_GPU_BUSY "GPU $gpu uses $used MiB. Stop other GPU workloads before launch."
    [[ "$power" =~ ^250([.]0+)?$ ]] || warn W_POWER "GPU $gpu power limit is $power W; results were measured at 250 W. No power setting was changed."
  done
  processes=$(nvidia-smi -i 0,1,2,3 --query-compute-apps=pid --format=csv,noheader,nounits) || fail E_GPU 'Cannot check GPU compute processes.'
  if [[ "$processes" =~ [0-9] ]]; then fail E_GPU_BUSY 'GPUs 0-3 have a compute process. Stop other GPU workloads before launch.'; fi
  log '[I_GPU] GPUs 0-3 have enough free memory and no compute workloads.'
}

check_disk() {
  local path ancestor device free need label docker_root i
  local -a paths=() sizes=() labels=()
  local -A need_by_device=() free_by_device=() names_by_device=()
  if ! weights_ready "$MODEL_DIR" "$MODEL_REVISION"; then paths+=("$MODEL_DIR"); sizes+=("$MODEL_FREE_GIB"); labels+=(checkpoint); fi
  if [[ "$(profile_value DRAFTER)" == dspark ]] && ! weights_ready "$DSPARK_DIR" "$DRAFTER_REVISION"; then paths+=("$DSPARK_DIR"); sizes+=("$DSPARK_FREE_GIB"); labels+=(DSpark); fi
  if ! image_ready; then
    docker_root=$(docker info --format '{{.DockerRootDir}}') || fail E_DISK 'Cannot locate Docker storage.'
    paths+=("$docker_root"); sizes+=("$IMAGE_FREE_GIB"); labels+=(image)
  fi
  if [[ ! -d "$CACHE_DIR/r0" ]]; then paths+=("$CACHE_DIR"); sizes+=("$CACHE_FREE_GIB"); labels+=(cache); fi
  for (( i=0; i<${#paths[@]}; i++ )); do
    path=${paths[i]}; need=${sizes[i]}; label=${labels[i]}; ancestor=$path
    while [[ ! -e "$ancestor" ]]; do ancestor=$(dirname -- "$ancestor"); done
    read -r device free < <(df -Pk -- "$ancestor" | awk 'END {print $1, $4}')
    [[ "$free" =~ ^[0-9]+$ ]] || fail E_DISK "Cannot inspect available disk space for $label."
    need_by_device[$device]=$(( ${need_by_device[$device]:-0} + need * 1024 * 1024 ))
    free_by_device[$device]=$free
    names_by_device[$device]="${names_by_device[$device]:-} $label"
  done
  for device in "${!need_by_device[@]}"; do
    (( free_by_device[$device] >= need_by_device[$device] )) || fail E_DISK "Need $((need_by_device[$device]/1024/1024)) GiB free for${names_by_device[$device]}; only $((free_by_device[$device]/1024/1024)) GiB available on that filesystem."
  done
  log '[I_DISK] Enough disk space for missing weights, image and kernel cache.'
  load_hf_token
  if [[ -n "${HF_TOKEN:-}" ]]; then log '[I_HF_TOKEN] Optional Hugging Face token is set; its value will not be printed.'
  else log '[I_HF_TOKEN] No Hugging Face token set; public downloads work without one. Set HF_TOKEN if access or rate limits require it.'; fi
}

# The same steps as the qualified build: a fresh upstream clone at the pinned commit, strict application of every
# engine patch, strict application of the build-context patches, then docker build. Offsets, fuzz, rejects and
# checksum drift all stop the build.
prepare_image() {
  local hash context
  hash=$(recipe_hash)
  if [[ "$DRY_RUN" != 1 ]] && image_ready; then log "Image is ready: $IMAGE ($hash)"; return; fi
  log "Build $IMAGE: clone TensorFold $ENGINE_VERSION at $ENGINE_COMMIT, apply the 151 engine patches and 4 build patches strictly."
  context="$STATE_DIR/build-$hash"
  if [[ "$DRY_RUN" == 1 ]]; then
    plan cp -a "$REPO_ROOT/build/recipe-base/." "$context/"
    plan git clone --no-checkout "$ENGINE_REPO" "$context/TensorFold"
    plan git -C "$context/TensorFold" checkout --detach "$ENGINE_COMMIT"
    plan bash "$REPO_ROOT/scripts/apply-patches.sh" "$context/TensorFold" --manifest "$REPO_ROOT/patches/series.json"
    plan bash "$REPO_ROOT/scripts/apply-patches.sh" "$context" --manifest "$REPO_ROOT/patches/recipe-series.json"
    plan docker build --label "org.aevonix.recipe=$hash" -t "$IMAGE" "$context"
    return
  fi
  [[ ! -e "$context" ]] || rm -rf -- "$context"
  mkdir -p "$context"
  cp -a "$REPO_ROOT/build/recipe-base/." "$context/"
  git clone --quiet --no-checkout "$ENGINE_REPO" "$context/TensorFold" || fail E_IMAGE 'Could not clone TensorFold. Check network access to GitHub.'
  git -C "$context/TensorFold" checkout --quiet --detach "$ENGINE_COMMIT" || fail E_IMAGE "Could not check out TensorFold $ENGINE_COMMIT."
  [[ "$(git -C "$context/TensorFold" rev-parse HEAD)" == "$ENGINE_COMMIT" ]] || fail E_IMAGE 'The TensorFold clone is not at the pinned commit.'
  bash "$REPO_ROOT/scripts/apply-patches.sh" "$context/TensorFold" --manifest "$REPO_ROOT/patches/series.json" >/dev/null || fail E_PATCHES 'An engine patch did not apply exactly. Restore the release patches/ directory and rerun.'
  bash "$REPO_ROOT/scripts/apply-patches.sh" "$context" --manifest "$REPO_ROOT/patches/recipe-series.json" >/dev/null || fail E_PATCHES 'A build patch did not apply exactly. Restore the release patches/ directory and rerun.'
  docker build --label "org.aevonix.recipe=$hash" -t "$IMAGE" "$context" || fail E_IMAGE 'Image build failed. Check disk space, network access and the first build error.'
  rm -rf -- "$context"
}

load_hf_token() {
  if [[ -z "${HF_TOKEN:-}" && -r "$HF_TOKEN_PATH" ]]; then
    IFS= read -r HF_TOKEN < "$HF_TOKEN_PATH" || true
  fi
  [[ -z "${HF_TOKEN:-}" ]] || export HF_TOKEN
}

fetch_weights() {
  local repo=$1 rev=$2 dir=$3
  if weights_ready "$dir" "$rev"; then log "Weights are ready: $repo @ $rev"; return; fi
  [[ "$DRY_RUN" == 1 ]] || mkdir -p "$dir"
  log "Download $repo at pinned revision $rev."
  # Pass the token by name so neither shell tracing here nor dry-run output prints its value.
  load_hf_token
  local -a token_args=(); [[ -z "${HF_TOKEN:-}" ]] || token_args=(-e HF_TOKEN)
  run docker run --rm --user "$(id -u):$(id -g)" -e HOME=/tmp -e HF_HOME=/tmp/huggingface "${token_args[@]}" -v "$dir:/dst" --entrypoint python "$IMAGE" -c \
    'import sys; from huggingface_hub import snapshot_download; snapshot_download(sys.argv[1], revision=sys.argv[2], local_dir="/dst")' "$repo" "$rev" || fail E_DOWNLOAD 'Weight download failed. Check free space, access and optional HF_TOKEN; rerun to resume.'
  [[ "$DRY_RUN" == 1 ]] || printf '%s\n' "$rev" > "$dir/.revision"
}

prepare_weights() {
  fetch_weights "$MODEL_ID" "$MODEL_REVISION" "$MODEL_DIR"
  if [[ "$DRY_RUN" != 1 ]]; then
    [[ "$(sha256sum "$MODEL_DIR/config.json" | cut -d' ' -f1)" == "$MODEL_CONFIG_SHA256" ]] || fail E_MODEL_CONFIG "config.json in $MODEL_DIR is not the qualified configuration. Remove $MODEL_DIR/.revision and rerun to download the pinned revision."
    log '[I_MODEL] Checkpoint configuration matches the qualified SHA256.'
  fi
  if [[ "$(profile_value DRAFTER)" == dspark ]]; then
    fetch_weights "$DRAFTER_ID" "$DRAFTER_REVISION" "$DSPARK_DIR"
  else
    [[ "$DRY_RUN" == 1 || -f "$DFLASH2_DIR/config.json" ]] || fail E_CONFIG "DFLASH2_DIR has no config.json: $DFLASH2_DIR"
    log 'DFlash2 weights are user-supplied (CC BY-NC-ND 4.0, non-commercial); this recipe never downloads them.'
  fi
}

# NCCL uses PCIe peer-to-peer for collectives in the measured configuration. Without peer access it falls back
# to slower transports, so a missing pair is reported as a warning.
check_peer_access() {
  run docker run --rm --gpus all -e CUDA_VISIBLE_DEVICES=0,1,2,3 --network none --entrypoint python "$IMAGE" -c \
    'import torch; assert torch.cuda.device_count() == 4, "Expected four CUDA GPUs"; missing = [(a,b) for a in range(4) for b in range(4) if a != b and not torch.cuda.can_device_access_peer(a,b)]; assert not missing, f"CUDA peer access unavailable: {missing}"; print("[I_P2P] CUDA peer access is available between all four GPUs.")' || warn W_P2P 'CUDA peer access is unavailable for some GPU pair. NCCL will use slower transports than the measured configuration.'
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  cd "$REPO_ROOT"
  case "${1:-}" in
    --label) printf '%s\n' "$(recipe_hash)"; exit 0 ;;
    ''|--image) ;;
    *) printf 'Usage: scripts/prepare.sh [--image|--label]\n' >&2; exit 2 ;;
  esac
  validate_config
  if [[ "$DRY_RUN" == 1 ]]; then log '[I_DRY_RUN] Plan only: no Docker, hardware access, downloads or file changes.'
  else
    check_platform
    mkdir -p "$STATE_DIR"
    exec 8>"$STATE_DIR/start.lock"
    flock -n 8 || fail E_LOCK 'Another start, stop or preparation is in progress.'
    check_disk
  fi
  prepare_image
  [[ "${1:-}" != --image ]] || exit 0
  prepare_weights
  log 'Prepared. Start the API with ./start.sh.'
fi
