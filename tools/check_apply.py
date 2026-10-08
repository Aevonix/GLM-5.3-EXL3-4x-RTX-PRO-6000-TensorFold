#!/usr/bin/env python3
"""Reproduce the release source from an unmodified TensorFold clone, without Docker or GPUs.

1. Clone TensorFold (default: the public repository) and check out the pinned v0.6.6 commit.
2. Apply patches/series.json with scripts/apply-patches.sh: no fuzz, offsets, rejects or checksum drift.
3. Stage the result and compare its Git tree ID with the tree of the qualified release source.
4. Rebuild the Docker build context from build/recipe-base and patches/recipe-series.json and compare
   the resulting Dockerfile and .dockerignore with their recorded SHA256 values.

Usage: python3 tools/check_apply.py [--upstream URL_OR_PATH] [--keep DIR]
Exit 0 when every comparison matches, 1 otherwise.
"""
import argparse
import hashlib
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TF_COMMIT = "cb2ebf0540f42604e2759b2ddef497861e928248"
EXPECTED_TREE = "2bb0ccebc8b59248049d426a7d92e870010797c7"
EXPECTED_CONTEXT = {
    "Dockerfile": "44efad84585163a26e5fcefa76089fd67312474002bdb808371ff0dd45e050c0",
    ".dockerignore": "ed4cba8294c72a22f8353e6b5a08a926127d974ea5984a851e61335702ee819c",
}


def git(where, *args):
    return subprocess.run(["git", "-C", str(where), *args], check=True, capture_output=True,
                          text=True).stdout.strip()


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--upstream", default="https://github.com/ashhart/TensorFold.git")
    ap.add_argument("--keep", type=Path, help="keep the replayed tree and build context in this new directory")
    a = ap.parse_args()
    work = Path(tempfile.mkdtemp(prefix="tf-replay-")) if a.keep is None else a.keep.resolve()
    if a.keep is not None:
        work.mkdir(parents=True, exist_ok=False)
    ok = True
    try:
        tree = work / "TensorFold"
        subprocess.run(["git", "clone", "--quiet", "--no-checkout", a.upstream, str(tree)], check=True)
        git(tree, "checkout", "--quiet", "--detach", TF_COMMIT)
        if git(tree, "rev-parse", "HEAD") != TF_COMMIT:
            print("FAIL: the clone is not at the pinned commit")
            return 1
        subprocess.run(["bash", str(ROOT / "scripts/apply-patches.sh"), str(tree),
                        "--manifest", str(ROOT / "patches/series.json")], check=True,
                       stdout=subprocess.DEVNULL)
        git(tree, "add", "-A")
        actual = git(tree, "write-tree")
        same = actual == EXPECTED_TREE
        ok &= same
        print(f"{'PASS' if same else 'FAIL'}: engine source tree {actual} (expected {EXPECTED_TREE})")
        context = work / "context"
        shutil.copytree(ROOT / "build/recipe-base", context)
        subprocess.run(["bash", str(ROOT / "scripts/apply-patches.sh"), str(context),
                        "--manifest", str(ROOT / "patches/recipe-series.json")], check=True,
                       stdout=subprocess.DEVNULL)
        for name, expected in EXPECTED_CONTEXT.items():
            digest = hashlib.sha256((context / name).read_bytes()).hexdigest()
            same = digest == expected
            ok &= same
            print(f"{'PASS' if same else 'FAIL'}: build context {name} {digest}")
    except subprocess.CalledProcessError as error:
        print(f"FAIL: {' '.join(map(str, error.cmd[:3]))} exited with {error.returncode}")
        ok = False
    finally:
        if a.keep is None:
            shutil.rmtree(work, ignore_errors=True)
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
