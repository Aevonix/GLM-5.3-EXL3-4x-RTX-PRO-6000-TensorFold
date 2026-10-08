#!/usr/bin/env bash
# One command: check, build, download, serve the measured production profile, wait for the API and smoke-test.
# Usage: ./start.sh [restart]
# Configuration: scripts/config.sh, scripts/local.sh, .env or exported environment; profiles/production.env.
# DRY_RUN=1 ./start.sh prints the full plan without Docker, GPUs or file changes.
# NO_ANIM=1 ./start.sh shows the static command deck; NO_COLOR=1 shows plain text.
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
# shellcheck source=scripts/prepare.sh
source ./scripts/prepare.sh
# shellcheck source=scripts/banner.sh
source ./scripts/banner.sh
case "${1:-}" in
  '') MODE=start ;;
  restart) MODE=restart ;;
  help|-h|--help) sed -n '2,6s/^# //p' "$0"; exit 0 ;;
  *) fail E_CONFIG 'Usage: ./start.sh [restart]. Set serving options in the environment or scripts/local.sh.' ;;
esac
(( $# <= 1 )) || fail E_CONFIG 'Usage: ./start.sh [restart].'
validate_config
banner
printf '\nAevonix Research TensorFold start\n%s | CP=%s | %s sessions | %s-token allocation | %s dense | %s KV | %s | port %s\n\n' \
  "$MODEL_ID" "$(profile_value CP)" "$(profile_value PARALLEL)" "$(profile_value CONTEXT)" "$(profile_value DENSE)" \
  "$(profile_value KV)" "$(profile_value DRAFTER)" "$PORT"
step() { printf '\n[%s/5] %s\n' "$1" "$2"; }
URL_HOST="$HOST"
[[ "$HOST" != 0.0.0.0 && "$HOST" != :: ]] || URL_HOST=127.0.0.1
[[ "$URL_HOST" != *:* ]] || URL_HOST="[$URL_HOST]"
URL="http://$URL_HOST:$PORT"

live_message() {
  brand_style
  printf '%sGLM-5.3 EXL3 is now LIVE! on port %s%s\n%sEndpoint: %s/v1%s\n' \
    "$AE_AMBER" "$PORT" "$AE_RESET" "$AE_TEAL" "$URL" "$AE_RESET"
}

# The optional upstream key is passed by environment name; never print it in a dry run.
api_curl() {
  if [[ -n "${TENSORFOLD_API_KEY:-}" ]]; then
    curl --header @<(printf 'Authorization: Bearer %s\n' "$TENSORFOLD_API_KEY") "$@"
  else
    curl "$@"
  fi
}

supervisor_alive() {
  local pid
  pid=$(cat "$STATE_DIR/serve.pid" 2>/dev/null || true)
  [[ "$pid" =~ ^[0-9]+$ ]] && kill -0 "$pid" 2>/dev/null
}
server_running() {
  supervisor_alive && return 0
  [[ "$(docker inspect -f '{{.State.Running}}' "$CONTAINER_PREFIX-r0" 2>/dev/null || true)" == true ]]
}

finish_start() {
  step 5 'Wait for the API and run a greedy smoke test'
  SMOKE_JSON=$(python3 - "$SERVED_NAME" <<'PY'
import json, sys
print(json.dumps({"model": sys.argv[1], "messages": [{"role": "user", "content": "Reply with exactly: ready"}], "temperature": 0, "max_tokens": 32, "chat_template_kwargs": {"enable_thinking": False}}))
PY
  )
  if [[ "$DRY_RUN" == 1 ]]; then
    plan curl --fail --silent --max-time 5 "$URL/v1/models"
    plan curl --fail --silent --show-error --max-time "$SMOKE_TIMEOUT" "$URL/v1/chat/completions" -H 'Content-Type: application/json' -d "$SMOKE_JSON"
    log 'Would validate a nonempty completion, then print:'
    live_message
    exit 0
  fi
  local started=$SECONDS heartbeat=$SECONDS
  until api_curl --fail --silent --max-time 5 "$URL/v1/models" | python3 -c 'import json,sys; assert json.load(sys.stdin).get("data")' >/dev/null 2>&1; do
    server_running || fail E_START "A rank exited. Inspect $RUN_LOG_DIR/server-rank*.log; ./stop.sh archives them."
    (( SECONDS - started < WAIT_TIMEOUT )) || fail E_API "API did not become ready within $WAIT_TIMEOUT seconds. Inspect $RUN_LOG_DIR/server-rank0.log; raise WAIT_TIMEOUT if kernels are still compiling."
    if (( SECONDS - heartbeat >= 30 )); then
      log "Waiting for the API: $((SECONDS - started)) seconds elapsed (loading about 273 GiB of weights; the first start also compiles kernels)."
      heartbeat=$SECONDS
    fi
    sleep 5
  done
  api_curl --fail --silent --show-error --max-time "$SMOKE_TIMEOUT" "$URL/v1/chat/completions" \
    -H 'Content-Type: application/json' -d "$SMOKE_JSON" > "$RUN_LOG_DIR/smoke.json" || fail E_SMOKE "Smoke request failed. Inspect $RUN_LOG_DIR/server-rank0.log and retry."
  python3 - "$RUN_LOG_DIR/smoke.json" <<'PY' || fail E_SMOKE "The smoke test returned no answer. Inspect $RUN_LOG_DIR/smoke.json and the rank logs."
import json, sys
with open(sys.argv[1], encoding="utf-8") as f:
    reply = json.load(f)
content = reply["choices"][0]["message"]["content"]
assert isinstance(content, str) and content.strip(), "Empty completion"
print("Smoke test passed: " + content.strip()[:120])
PY
  printf '\nHealth: %s/health\nLogs: %s/server-rank0.log\n' "$URL" "$RUN_LOG_DIR"
  live_message
}

step 1 'Check Linux, Docker, NVIDIA runtime, GPUs 0-3, disk space and optional download token'
if [[ "$DRY_RUN" == 1 ]]; then
  log '[I_DRY_RUN] Plan only: hardware checks skipped; no Docker commands, downloads or file changes are executed.'
  log "Check Linux x86_64, docker group/access, NVIDIA runtime, four idle GPUs (0-3) with $MIN_GPU_FREE_MIB MiB free each, free disk and optional HF_TOKEN."
  log 'Warn if power limits differ from the measured 250 W; never change them.'
  if [[ "$MODE" == restart ]]; then DRY_RUN=1 "$REPO_ROOT/stop.sh"; fi
else
  check_platform
  mkdir -p "$STATE_DIR"
  exec 8>"$STATE_DIR/start.lock"
  flock -n 8 || fail E_LOCK 'Another start, stop or preparation is in progress.'
  if server_running; then
    if [[ "$MODE" == start ]]; then
      log "The server is already running. Endpoint: $URL/v1"
      log 'Use ./start.sh restart to apply changed settings, or ./stop.sh to stop it.'
      RUN_LOG_DIR=$(cat "$STATE_DIR/serve.run" 2>/dev/null || true)
      [[ -d "$RUN_LOG_DIR" ]] || fail E_LOG 'The running server has no recorded log directory. Stop it with ./stop.sh and start again.'
      finish_start
      exit 0
    fi
    # Settings were validated before an existing server is stopped. Its logs are archived first.
    GLM_STOP_LOCK_HELD=1 "$REPO_ROOT/stop.sh"
  fi
  for rank in 0 1 2 3; do
    ! docker container inspect "$CONTAINER_PREFIX-r$rank" >/dev/null 2>&1 || fail E_START "A container named $CONTAINER_PREFIX-r$rank already exists. Run ./stop.sh or remove it."
  done
  check_gpus
  check_disk
  python3 - "$HOST" "$PORT" "$MASTER_PORT" <<'PY' || fail E_PORT 'API or rendezvous port is in use. Stop its owner or change PORT / MASTER_PORT.'
import socket, sys
for host, port in ((sys.argv[1], int(sys.argv[2])), ("127.0.0.1", int(sys.argv[3]))):
    family = socket.AF_INET6 if ":" in host else socket.AF_INET
    with socket.socket(family, socket.SOCK_STREAM) as sock:
        sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        sock.bind((host, port))
PY
fi

step 2 'Build the pinned TensorFold image with all 151 engine patches (skip when ready)'
prepare_image
step 3 'Download the pinned checkpoint and DSpark drafter (skip when ready)'
prepare_weights

step 4 'Start four TensorFold ranks with profiles/production.env (serve.sh, one container per GPU)'
check_peer_access
RUN_LOG_DIR="$LOG_DIR/run-$(date -u +%Y%m%dT%H%M%SZ)-$$"
# The same variables the measured deployment sets before it runs serve.sh; the profile supplies the rest.
SERVE_ENV=(IMAGE="$IMAGE" PROFILE="$PROFILE" MODEL_DIR="$MODEL_DIR" DRAFTER_DIR="$DRAFTER_DIR" CACHE_DIR="$CACHE_DIR"
  LOG_DIR="$RUN_LOG_DIR" RUN=server PORT="$PORT" API_HOST="$HOST" MASTER_PORT="$MASTER_PORT"
  CONTAINER_PREFIX="$CONTAINER_PREFIX" SERVED_NAME="$SERVED_NAME" MAX_TOKENS="$MAX_TOKENS" TF_GLM_MEMORY_RECEIPT=1)
if [[ "$DRY_RUN" == 1 ]]; then
  plan env "${SERVE_ENV[@]}" setsid nohup "$REPO_ROOT/serve.sh"
  log "Ranks 0-3 run on GPUs 0-3 as containers $CONTAINER_PREFIX-r0 to -r3, each seeing its own GPU first."
else
  mkdir -p "$RUN_LOG_DIR" "$CACHE_DIR"
  ln -sfn -- "$RUN_LOG_DIR" "$LOG_DIR/current"
  printf '%s\n' "$RUN_LOG_DIR" > "$STATE_DIR/serve.run"
  rm -f -- "$STATE_DIR/serve.pid"
  # A separate session keeps the ranks running after this terminal closes; ./stop.sh ends them.
  # The supervisor must not inherit the start lock (descriptor 8), or ./stop.sh could never take it.
  setsid nohup bash -c 'printf "%s\n" "$$" > "$1"; shift; exec "$@"' supervisor "$STATE_DIR/serve.pid" \
    env "${SERVE_ENV[@]}" "$REPO_ROOT/serve.sh" > "$RUN_LOG_DIR/serve.log" 2>&1 < /dev/null 8>&- &
  for _ in $(seq 50); do [[ -s "$STATE_DIR/serve.pid" ]] && break; sleep 0.1; done
  supervisor_alive || fail E_START "serve.sh exited at once. Inspect $RUN_LOG_DIR/serve.log."
  log "Ranks are starting. Logs: $RUN_LOG_DIR"
fi

finish_start
