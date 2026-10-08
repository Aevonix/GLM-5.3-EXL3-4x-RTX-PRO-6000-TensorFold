#!/usr/bin/env bash
# Apply an ordered patch manifest (patches/series.json for the engine, patches/recipe-series.json for the build
# context) to a tree, refusing fuzz, offsets, rejects and checksum drift.
# Usage: scripts/apply-patches.sh TREE [--manifest patches/series.json]
set -euo pipefail
APPLY_PATCHES_ROOT=$(cd "$(dirname "$0")/.." && pwd) exec python3 -c "$(cat <<'PY'
"""Apply the ordered manifest, refusing fuzz, offsets, rejects and checksum drift."""
import argparse
import hashlib
import json
import os
import re
import subprocess
from pathlib import Path


def apply(tree, patch, strip=0, subdir='src'):
    cwd = tree / subdir
    args = ['patch', f'-p{strip}', '--batch', '--forward', '--fuzz=0',
            '--no-backup-if-mismatch', '-i', str(patch.resolve())]
    # Diagnostic matching must not depend on the caller's locale.
    env = dict(os.environ, LC_ALL='C', LANG='C')
    logs = []
    for extra in (['--dry-run'], []):
        result = subprocess.run([*args, *extra], cwd=cwd, env=env,
                                capture_output=True, text=True)
        log = result.stdout + result.stderr
        if result.returncode or re.search(r'offset|fuzz|FAILED|malformed|Reversed', log, re.I):
            raise RuntimeError(f'{patch.name}: refused inexact application\n{log}')
        logs.append(log)
    return logs[0]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('tree', type=Path)
    parser.add_argument('--manifest', type=Path,
                        default=Path(os.environ['APPLY_PATCHES_ROOT']) / 'patches' / 'series.json')
    args = parser.parse_args()
    for entry in json.loads(args.manifest.read_text()):
        patch = args.manifest.parent / entry['path']
        if hashlib.sha256(patch.read_bytes()).hexdigest() != entry['sha256']:
            raise RuntimeError(f'{patch.name}: checksum mismatch')
        apply(args.tree, patch, entry['strip'], entry['cwd'])
        print(entry['path'], flush=True)


if __name__ == '__main__':
    main()
PY
)" "$@"
