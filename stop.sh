#!/usr/bin/env bash
# Stop the four ranks, save one gzipped archive with their logs and keep the newest LOG_KEEP (10).
# Usage: ./stop.sh; DRY_RUN=1 ./stop.sh prints the plan and changes nothing.
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
# shellcheck source=scripts/prepare.sh
source ./scripts/prepare.sh
[[ "$STOP_TIMEOUT" =~ ^[1-9][0-9]*$ && "$LOG_KEEP" =~ ^[1-9][0-9]*$ ]] || fail E_CONFIG 'STOP_TIMEOUT and LOG_KEEP must be positive integers.'
if [[ "$DRY_RUN" == 1 ]]; then
  log '  Send TERM to the serve.sh supervisor recorded in .state/serve.pid; it stops every rank container.'
  for rank in 0 1 2 3; do plan docker stop -t 10 "$CONTAINER_PREFIX-r$rank"; done
  log "  Save the run's rank logs as $LOG_DIR/glm53-<timestamp>.tar.gz; keep newest $LOG_KEEP archives."
  exit 0
fi
command -v docker >/dev/null || fail E_DEPENDENCY 'Missing command: docker.'
docker info >/dev/null 2>&1 || fail E_DOCKER 'Cannot talk to Docker. Start the daemon and check socket permissions.'
if [[ "${GLM_STOP_LOCK_HELD:-0}" != 1 ]]; then
  mkdir -p "$STATE_DIR"
  exec 8>"$STATE_DIR/start.lock"
  flock -n 8 || fail E_LOCK 'Another start, stop or preparation is in progress.'
fi
pid=$(cat "$STATE_DIR/serve.pid" 2>/dev/null || true)
run_logs=$(cat "$STATE_DIR/serve.run" 2>/dev/null || true)
found=0
if [[ "$pid" =~ ^[0-9]+$ ]] && kill -0 "$pid" 2>/dev/null && grep -qaE 'start-integrated[.]sh|serve[.]sh' "/proc/$pid/cmdline" 2>/dev/null; then
  found=1
  log "Stopping the ranks (up to $STOP_TIMEOUT seconds; active requests will end)."
  kill -TERM "$pid"
  for (( waited = 0; waited < STOP_TIMEOUT * 10; waited++ )); do kill -0 "$pid" 2>/dev/null || break; sleep 0.1; done
fi
for rank in 0 1 2 3; do
  if docker container inspect "$CONTAINER_PREFIX-r$rank" >/dev/null 2>&1; then
    found=1
    docker stop -t 10 "$CONTAINER_PREFIX-r$rank" >/dev/null || fail E_STOP "Docker could not stop $CONTAINER_PREFIX-r$rank. Inspect docker ps and retry."
  fi
done
if [[ "$pid" =~ ^[0-9]+$ ]] && kill -0 "$pid" 2>/dev/null && grep -qaE 'start-integrated[.]sh|serve[.]sh' "/proc/$pid/cmdline" 2>/dev/null; then
  fail E_STOP "The serve.sh supervisor ($pid) is still running after its ranks stopped. Inspect it before retrying."
fi
rm -f -- "$STATE_DIR/serve.pid" "$STATE_DIR/serve.run"
if [[ -z "$run_logs" || ! -d "$run_logs" ]]; then
  (( found )) && log 'Stopped. No run log directory was recorded.' || log 'No running server. Nothing to stop.'
  exit 0
fi
mkdir -p "$LOG_DIR"
archive="$LOG_DIR/glm53-$(date -u +%Y%m%dT%H%M%SZ)-$$.tar.gz"
tar -czf "$archive.tmp" -C "$run_logs" . || fail E_LOG "Could not archive logs. Check LOG_DIR space and permissions; $run_logs was kept."
mv -- "$archive.tmp" "$archive"
# Delete raw logs only after a successful archive and only in this recipe-owned run directory.
if [[ "$run_logs" == "$LOG_DIR"/run-* && ! -L "$run_logs" ]]; then
  rm -rf -- "$run_logs"
  [[ ! -L "$LOG_DIR/current" || "$(readlink -- "$LOG_DIR/current")" != "$run_logs" ]] || rm -- "$LOG_DIR/current"
fi
python3 - "$LOG_DIR" "$LOG_KEEP" <<'PY'
from pathlib import Path
import sys
archives = sorted(Path(sys.argv[1]).glob("glm53-*.tar.gz"), key=lambda p: p.stat().st_mtime_ns, reverse=True)
for path in archives[int(sys.argv[2]):]:
    path.unlink()
PY
log "Stopped. Logs saved to $archive (newest $LOG_KEEP kept)."
