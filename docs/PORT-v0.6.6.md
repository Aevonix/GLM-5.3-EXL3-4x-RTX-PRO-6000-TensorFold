# Rebase to v0.6.6

The 151 engine patches now apply strictly to TensorFold v0.6.6
(`cb2ebf0540f42604e2759b2ddef497861e928248`). The previous base was v0.6.5
(`609ca419abecebdc5a059498a613680bd3aa847f`). Patch order, filenames and attribution are unchanged.

This is a rebase only. Nine regenerated patches remain credited to Mia's AI Lab, with their original header lines.
One regenerated patch is from Aevonix Research. The other 141 engine patches are byte-identical to the previous
series. The [original port notes](PORT-v0.6.5.md) retain Mia's donor SHA256s at `885f5c8` and the original
v0.6.5 classifications. The hashes below identify this recipe's patch files before and after the rebase.

## Exact tree comparison

OLD is v0.6.5 with the original 151 patches applied by `scripts/apply-patches.sh`.
EXPECTED is OLD with upstream commits `dce62cf`, `07f3777` and `cb2ebf0` cherry-picked in that order.
All three cherry-picks completed cleanly. There were no conflicts or manual resolutions.
REBASED is v0.6.6 with the regenerated series applied by the same strict applier.

| Tree | Git tree SHA |
|---|---|
| OLD | `ee3aad92acb885e6a48c28ad04f7c9f91ae6fb93` |
| EXPECTED | `2bb0ccebc8b59248049d426a7d92e870010797c7` |
| REBASED | `2bb0ccebc8b59248049d426a7d92e870010797c7` |

The identical EXPECTED and REBASED trees preserve the complete recipe behavior plus upstream's v0.6.6 change.
The upstream change adds CUDA server `--name-priority ID=background` support and updates the version.
Only its eight files differ between OLD and EXPECTED: `CHANGELOG.md`, `docs/api.md`,
`src/tensorfold/__init__.py`, `src/tensorfold/cli.py`, `src/tensorfold/cli_args.py`,
`src/tensorfold/cuda/server.py`, `src/tensorfold/serve_options.py` and `tests/test_cuda_name_priority.py`.

## Regenerated patches

Upstream insertions moved existing recipe hunks. Only 36 `@@` hunk line positions changed across these 10 patches.
All added and removed payload lines, context lines, hunk lengths, filenames, patch preambles and index lines remain
byte-identical. No behavior or conflict edit was required. Updating the recorded line positions lets the strict
applier replay every patch without an offset or fuzz. Each new SHA256 is pinned in
[`patches/series.json`](../patches/series.json).

Paths in this table are relative to `patches/`, in application order.

| Patch | Changed hunk headers | Previous SHA256 | v0.6.6 SHA256 |
|---|---:|---|---|
| `miaai-lab/0003-glm-vision.patch` | 2 | `f87c137295d1e12127d51edd92f261ff19f277937bfdd6b5e69d1fdadf7d8b6d` | `ea0848e1431c3df3849e61890ef5f56ff4b7a0e0074180a4346e1716e2843d35` |
| `miaai-lab/0036-glm-tool-calls.patch` | 6 | `7ad3162cb6a7b2b93c3ed5ef85debc482f7fcff91ca95a280bb6cf1d4aa89723` | `8b13ac39ce035eedeabe3f12984bdc163fe3ff648bba14070d19315aa285ac0e` |
| `miaai-lab/0053-glm-whole-tool-calls.patch` | 3 | `f5c3a3d64c2174470694336897d70da368f9b678591a7a67e6fda4fba69839d7` | `be859822bae3a2d05467ff969b14645a7f142bea0f07536a6418dccb61a2c320` |
| `miaai-lab/0055-glm-open-tool-calls.patch` | 4 | `a2755f3e962fc5235966d7dafeae6f2d0a9390799e3a54b583513c18cde3827d` | `5ef64347096bba436bb6af22613561563529bb93c3031351d83316782dd779a2` |
| `miaai-lab/0056-glm-tool-result-media.patch` | 3 | `59663dd6697ac67c3a1427eb493de975fed7ada77ef0ab18d32646fe6408cc60` | `767136e6271fcce5c206f09c32821eba28844566ea89bb62f6a1af47ec995bce` |
| `miaai-lab/0061-server-smooth-stream.patch` | 3 | `f494cce7e04a1d66c50abd00ae6ba02a73e7b37b96a2e1e4dfee73994446c30e` | `c0920d7a81f501d3738c028bf61fff5d9b90a0ffe292179a90b32f7fa8e00a29` |
| `miaai-lab/0062-glm-sliced-fill.patch` | 1 | `8d7236dacdaf08c92acb1e162894e7cf6a43a092b94339a48ba5e5b5c72817cc` | `5df7fa5c52b96dfdfa00278fa66b9e1f0a5dba0b6dc176ddb0c5159489230c50` |
| `miaai-lab/0066-glm-tp-n.patch` | 4 | `a76877abae73bf3a83edd1d92ad042b5a5f08b5b36dd24bf7dcfa60b5d6b26af` | `a2bd9a91cdb63dd007d97ac880d0fecb4b32659f1683f1279498c1ba221179ef` |
| `miaai-lab/0122-glm-full-serial-stop.patch` | 1 | `a2d79888e3fe67d3b028882e7d881008870c22cdf9902132663e1f6454707147` | `adefde746f7e87bb1338c38bbbe9ce945819767137618f9401b40343a9d25966` |
| `aevonix/aevonix-mia-100-server-contract.patch` | 9 | `da08033c5f2f832653c7729b81d144f13d574dad1125a81af39a6b61255ad8de` | `342babbe3f969c3847be3dce8c5fd3f6b57f8803b6fdaa47f973ca75a62637cc` |

The changed hunk positions belong to these source files. Other hunks in each patch retain their original bytes.
Mia's patch paths omit the `src/` prefix; the paths below include it to identify the files in TensorFold.

| Patch | Files with adjusted hunk positions |
|---|---|
| `0003-glm-vision.patch` | `src/tensorfold/cuda/server.py`, `src/tensorfold/serve_options.py` |
| `0036-glm-tool-calls.patch` | `src/tensorfold/cuda/server.py` |
| `0053-glm-whole-tool-calls.patch` | `src/tensorfold/cuda/server.py` |
| `0055-glm-open-tool-calls.patch` | `src/tensorfold/cuda/server.py` |
| `0056-glm-tool-result-media.patch` | `src/tensorfold/cuda/server.py` |
| `0061-server-smooth-stream.patch` | `src/tensorfold/cuda/server.py` |
| `0062-glm-sliced-fill.patch` | `src/tensorfold/cuda/server.py` |
| `0066-glm-tp-n.patch` | `src/tensorfold/cli.py`, `src/tensorfold/cli_args.py` |
| `0122-glm-full-serial-stop.patch` | `src/tensorfold/cuda/server.py` |
| `aevonix-mia-100-server-contract.patch` | `src/tensorfold/cuda/server.py` |

## Build context

The four patches in [`patches/recipe-series.json`](../patches/recipe-series.json) apply to `build/recipe-base`.
They are unaffected by the TensorFold rebase. All four patch files, their SHA256 pins and the base build files
are unchanged. Strict replay of the build series still reproduces the recorded build-context hashes.

This source comparison establishes tree identity. The separate [v0.6.6 validation notes](NOTES.md#tensorfold-v066)
record native A/B runtime checks on the Server Edition host. Published measurements remain attributed to the
v0.6.5 build on the Max-Q host.
