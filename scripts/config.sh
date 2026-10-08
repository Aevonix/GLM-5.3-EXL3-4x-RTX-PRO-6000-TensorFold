#!/usr/bin/env bash
# Settings in precedence order: exported environment, scripts/local.sh, .env, then the defaults below and
# profiles/production.env. local.sh is trusted Bash. .env is read as literal KEY=value lines, never executed.
# serve.sh applies the profile only to keys the environment does not already set, so any profile key set
# here (for example CONTEXT or PARALLEL) is exported and overrides the measured production value.
[[ "${_GLM_CONFIG_LOADED:-0}" == 1 ]] && return 0
_GLM_CONFIG_LOADED=1
REPO_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
if [[ -f "$REPO_ROOT/scripts/local.sh" ]]; then
  declare -A _cfg_env=()
  while IFS= read -r _cfg_key; do _cfg_env[$_cfg_key]=${!_cfg_key}; done < <(compgen -e)
  # shellcheck source=/dev/null
  source "$REPO_ROOT/scripts/local.sh"
  for _cfg_key in "${!_cfg_env[@]}"; do export "$_cfg_key=${_cfg_env[$_cfg_key]}"; done
  unset _cfg_env
fi
if [[ -f "$REPO_ROOT/.env" ]]; then
  while IFS= read -r _cfg_line || [[ -n "$_cfg_line" ]]; do
    [[ "$_cfg_line" =~ ^[[:space:]]*(export[[:space:]]+)?([A-Za-z_][A-Za-z0-9_]*)=(.*)$ ]] || continue
    _cfg_key=${BASH_REMATCH[2]}; _cfg_value=${BASH_REMATCH[3]}
    if [[ "$_cfg_value" =~ ^\"([^\"]*)\"[[:space:]]*(#.*)?$ || "$_cfg_value" =~ ^\'([^\']*)\'[[:space:]]*(#.*)?$ ]]; then
      _cfg_value=${BASH_REMATCH[1]}
    else
      _cfg_value=${_cfg_value%%#*}; _cfg_value=${_cfg_value%"${_cfg_value##*[![:space:]]}"}
    fi
    [[ -n "${!_cfg_key+set}" ]] || export "$_cfg_key=$_cfg_value"
  done < "$REPO_ROOT/.env"
fi
unset _cfg_key _cfg_line _cfg_value

# Pinned software and weights. Downloads are made directly from their publishers.
ENGINE_VERSION=v0.6.6
ENGINE_COMMIT=cb2ebf0540f42604e2759b2ddef497861e928248
ENGINE_REPO="${ENGINE_REPO:-https://github.com/ashhart/TensorFold.git}"
IMAGE="${IMAGE:-tensorfold-glm53-full:1.1.0}"
MODEL_ID=Mia-AiLab/GLM-5.3-EXL3-2.75bpw-TensorFold
MODEL_REVISION=2d747d0e30eca6e3fe37ba63c471cdf9172faa83
MODEL_CONFIG_SHA256=e7d294bdc0623e585e90d55444b3dc930c3b94fa1a3261fb7ba2116e94855ad0
DRAFTER_ID=RedHatAI/GLM-5.3-speculator.dspark
DRAFTER_REVISION=b374b95663447ea0e935151be4f3d6666e36e6d7
DATA_DIR="${DATA_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/aevonix-glm53-full}"
MODEL_DIR="${MODEL_DIR:-$DATA_DIR/model}"
DSPARK_DIR="${DSPARK_DIR:-$DATA_DIR/dspark}"
DFLASH2_DIR="${DFLASH2_DIR:-}"                  # optional, user-supplied; never downloaded by this recipe
CACHE_DIR="${CACHE_DIR:-$DATA_DIR/cache}"        # per-rank r0-r3: compiled kernels and parked prompts
HF_TOKEN_PATH="${HF_TOKEN_PATH:-${HF_HOME:-$HOME/.cache/huggingface}/token}" # optional local login token
STATE_DIR="${STATE_DIR:-$REPO_ROOT/.state}"
LOG_DIR="${LOG_DIR:-$REPO_ROOT/logs}"
LOG_KEEP="${LOG_KEEP:-10}"                       # newest 10 compressed session logs

# One host. serve.sh starts one container per rank and maps ranks 0-3 to host GPUs 0-3.
PROFILE="${PROFILE:-$REPO_ROOT/profiles/production.env}"
PORT="${PORT:-8030}"
HOST="${HOST:-0.0.0.0}"
MASTER_PORT="${MASTER_PORT:-29591}"
SERVED_NAME="${SERVED_NAME:-glm-5.3}"
MAX_TOKENS="${MAX_TOKENS:-32768}"
CONTAINER_PREFIX="${CONTAINER_PREFIX:-glm53-tf}"

# Setup and checks. DRY_RUN prints plans and commands without running Docker or touching GPUs.
DRY_RUN="${DRY_RUN:-0}"
WAIT_TIMEOUT="${WAIT_TIMEOUT:-3600}"            # seconds for API readiness, including first-start kernel builds
SMOKE_TIMEOUT="${SMOKE_TIMEOUT:-300}"
STOP_TIMEOUT="${STOP_TIMEOUT:-90}"
MIN_GPU_FREE_MIB="${MIN_GPU_FREE_MIB:-95000}"   # per GPU; the measured profile peaked at 94,636 MiB
MODEL_FREE_GIB="${MODEL_FREE_GIB:-280}"          # first-download budgets
DSPARK_FREE_GIB="${DSPARK_FREE_GIB:-5}"
IMAGE_FREE_GIB="${IMAGE_FREE_GIB:-40}"
CACHE_FREE_GIB="${CACHE_FREE_GIB:-40}"

# Keys of the measured production profile, and their effective values for checks and the start summary.
PROFILE_KEYS=()
if [[ -f "$PROFILE" ]]; then
  while IFS='=' read -r _cfg_key _cfg_value; do
    [[ -z "$_cfg_key" || "$_cfg_key" == \#* ]] && continue
    PROFILE_KEYS+=("$_cfg_key")
    # A profile key set by local.sh or .env must be exported to reach serve.sh.
    if [[ -n "${!_cfg_key+set}" && "$_cfg_key" =~ ^[A-Z][A-Z0-9_]*$ ]]; then export "${_cfg_key?}"; fi
  done < "$PROFILE"
fi
unset _cfg_key _cfg_value
profile_value() {
  local key=$1 k v
  if [[ -n "${!key+set}" ]]; then printf '%s' "${!key}"; return; fi
  [[ -f "$PROFILE" ]] || return 0
  while IFS='=' read -r k v; do
    [[ "$k" == "$key" ]] && { printf '%s' "$v"; return; }
  done < "$PROFILE"
}
