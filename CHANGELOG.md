# Changelog

## 1.1.0 (2026-10-08)

- Rebased the 151 engine patches onto TensorFold v0.6.6 at `cb2ebf0540f42604e2759b2ddef497861e928248`.
- The engine adds `--name-priority ID=background`. Requests to that served ID default to background priority;
  an explicit request priority still wins.
- Regenerated 10 patches by updating hunk positions only. This is a rebase only. Mia's AI Lab's patches remain hers;
  patch payloads, order and attribution are unchanged. The resulting tree equals the previous tree plus upstream's
  three commits.
- Native A/B validation on four RTX PRO 6000 Blackwell Server Edition GPUs passed identical gate and gatelong
  results, 40/40 first-token comparisons, matching tool bursts and the name-priority smoke test. No regression was
  observed. Four-stream decode has a process warm-state limitation, so no speed gain is claimed. Published
  measurements remain attributed to the v0.6.5 build on the Max-Q host. See [validation notes](docs/NOTES.md).

## 1.0.0 (2026-10-06)

- First release by Aevonix Research: our full GLM-5.3 build for one Linux host with four RTX PRO 6000 Blackwell GPUs.
- TensorFold v0.6.5 with 151 engine patches: 106 of Mia's AI Lab's full GLM-5.3 patches, ported from v0.6.0, and 45
  Aevonix Research patches. Four build patches pin the NVIDIA base image and the server dependencies.
- Measured profile: context parallelism over four GPUs, FP8 dense and KV, the DSpark drafter, five sessions, a
  1,048,576-token allocation per request, a 1,245,184-token shared pool and RAM and NVMe prompt tiers.
- One-command setup and launch around the measured launcher: checks, a strict build from a fresh upstream clone,
  pinned downloads with a configuration hash check, readiness and a smoke test. Restart, dry run and ten saved log
  archives.
- Qualification results for exactness, identity, the server contract, teacher KL, populated sessions, cold prefill,
  prompt resume and retrieval, including the two retrieval misses near the limit. A source replay check reproduces the
  release tree from an unmodified TensorFold clone.
