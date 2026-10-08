# Patches

The image applies 151 engine patches to TensorFold v0.6.6 (`cb2ebf0540f42604e2759b2ddef497861e928248`) in the
order of [`patches/series.json`](../patches/series.json), which is not filename order, and 4 build patches to the
Docker build context in the order of [`patches/recipe-series.json`](../patches/recipe-series.json). Both manifests
pin every file's SHA256. `scripts/apply-patches.sh` refuses fuzz, offsets, rejects and checksum drift, and
[`tools/check_apply.py`](../tools/check_apply.py) reproduces the rebased source tree from an unmodified clone.
The [v0.6.6 rebase notes](PORT-v0.6.6.md) record the 10 regenerated patches and exact tree comparison.

| Folder | Patches | Origin |
|---|---:|---|
| `patches/miaai-lab/` | 106 | Mia's AI Lab's full GLM-5.3 recipe, originally ported from TensorFold v0.6.0 to v0.6.5 ([port notes](PORT-v0.6.5.md)), then [rebased to v0.6.6](PORT-v0.6.6.md) |
| `patches/aevonix/` | 45 | Aevonix Research: single-host serving, concurrent context-parallel sessions, kernels and prompt-cache tiers |
| `patches/build/` | 4 | Aevonix Research: image packaging and runtime pins |

**Exactness boundary.** FP8 dense layers and FP8 KV change numerics relative to the checkpoint's BF16 tensors.
Patches marked *exact* below keep the fixed configuration's outputs: they were checked with drafted-versus-serial and
concurrent-versus-solo token identity, byte comparisons or both. A measured effect from a historical or donor build is
labeled as such; it is not an isolated gain of the current image. Published measurements are from the v0.6.5 build
or the earlier builds named below. They are in the [README](../README.md#performance) and [validation notes](NOTES.md),
alongside the separate v0.6.6 A/B validation.

## Aevonix Research engine patches

Listed in application order. The serving switches are set in [`profiles/production.env`](../profiles/production.env)
or by `serve.sh`.

| Patch | Switch | What it changes | Measured effect and limits |
|---|---|---|---|
| `0000-glm-exl3-route` | `TF_GLM_EXL3_PATH` | Keeps GLM's own EXL3 expert kernels beside upstream's universal route; full GLM keeps its mixed-width route. Carried over from our GLM-5.3-Flash port. | Source audit and CPU tests; no speed claim. |
| `aevonix-mia-100-server-contract` | none | Rebases request validation, answer-channel stops and incremental tool-call streaming onto the upstream server. | Contract tests pass; raw model tokens matched the baseline on 80/80 requests. Final server audit: 87 requests, 313 checks. |
| `aevonix-mia-120-communicator` | none | Registers RoCE in `open_comm`, keeps independent NCCL send and receive lengths, and agrees on the transport across ranks. | Communicator tests pass. This host uses NCCL over PCIe; no RoCE runtime claim. |
| `aevonix-mia-003-before-warmup-memory` | `TF_MEMORY_LOG` | Optional free, allocated and reserved memory report before graph warmup. | Diagnostic only. |
| `aevonix-mia-121-server-tests` | none | The server test reader accepts upstream usage-only SSE chunks. | Test only. |
| `aevonix-mia-122-tpn-decisions` | none | Gathers vocabulary shards of any width across ranks for decision scoring and rejects scoring the multi-request loop cannot carry. | CPU tests for asymmetric exchanges and backend registration. |
| `aevonix-mia-123-thinking-and-api-fixtures` | none | Supports both thinking-option constructor conventions, keeps environment validation and preserves explicit request behavior. | Thinking and HTTP contract tests pass; 80/80 raw model-token comparisons match the baseline. |
| `aevonix-mia-124` and `-125` | none | Complete fake application fields and capacity fixtures for index rings, the verify reserve and one-pass scratch. | Test fixtures only; no runtime source change. |
| `aevonix-mia-126-tpn-startup-and-diagnostics` | none | Opens early connections to every peer before large allocations and names the actual follower rank in integrity errors. | Admission and communicator CPU subset passes. |
| `aevonix-mia-010-dspark-controls` | `TF_GLM_DSPARK_BLOCK`, `TF_GLM_DSPARK_MOST`, `TF_GLM_DSPARK_POLICY` | DSpark block size and cost-policy controls. | Historical CP=1 control: +1.82% paired per-request geometric mean over its wide-graph control, with a 3.28% tools-suite regression. *Exact*. |
| `aevonix-mia-012-nccl-exchange-comm` | `TF_NCCL_EXCHANGE_ENV` | A separate NCCL communicator for exchanges, so peer-to-peer can be disabled for exchanges only. | Historical CP=1 control: suite medians +18.5% to +26.4%. *Exact*: identical speculative work on all 80 requests. |
| `aevonix-mia-016-fp8-shape-tiles` | `TF_GLM_F8_SHAPE_TILES` | Shape-specific FP8 decode launch tiles; the numerical operation is unchanged. | Part of a combined +1.09% profile result; not attributable alone. |
| `aevonix-mia-018-fp8-prompt-tiles` | `TF_GLM_F8_PROMPT_TILES` | FP8 prompt tiles for larger prompt batches. | With the tuned transport and profile, historical 32K cold TTFT fell from 56.2 to 17.0 seconds; a profile comparison, not an isolated tile gain. |
| `aevonix-mia-030`, `-032`, `-033` (`v065`) | `DRAFTER=dflash2` | Optional BF16 DFlash2 drafter on the full model: compatibility, host codebooks excluded from GPU admission (302.5 MiB per rank), vocabulary-sharded embedding and head. | The production default is DSpark. This optional single-request path is not qualified on the final image. |
| `aevonix-mia-047-parallel-cp-topk` | `TF_MIA_PAR_TOPK` | Exact parallel context-parallel top-k selection. | Selector time about 219 to 41 microseconds at 256K and about 860 to 43-66 microseconds at 1M; selector timings, not full-model gains. *Exact*. |
| `aevonix-mia-046-cp-sparse-chunks` | `TF_MIA_CP_CHUNK`, `TF_MIA_CP_WARPS`, `TF_MIA_CP_STAGES` | Sparse-attention chunk, warp and stage controls; the profile selects 512/8/2. | About 7% faster in isolated screening; 100 changing-query graph comparisons pass. A 64-row chunk changed output bits and is not used. |
| `aevonix-mia-045-index-query-reuse` | none | Reuses grouped index queries with byte-identical results. | *Exact*; no independent speed claim. |
| `aevonix-mia-060-cp-concurrent-extents` | `TF_GLM_CP_POOL_TOKENS` | Independent concurrent context-parallel extents within one total token budget. | Capacity change; the measured concurrency comes with patches 130-134 and 200-202. |
| `aevonix-mia-061-lean-buffers` | `TF_GLM_LEAN_BUFFERS` | Omits target and MTP scratch the selected path does not use. | Memory only. |
| `aevonix-mia-063-paged-cp-reference` | none | A shared physical page pool with bounded staging instead of a full logical window per session. | Covered by the full-model and native-page byte gates. |
| `aevonix-mia-130-concurrent-cp-graphs` | `TF_GLM_CP_MULTI_GRAPHS` | Captures concurrent verification as CUDA graphs with position-aware page copies. | Final latency window: 14,547 graph replays and zero eager fallbacks. |
| `aevonix-mia-017-graph-boundary` | `TF_GLM_GRAPH_BOUNDARY` | Clips a verify block at the dense/sparse graph boundary so it stays on the graph route. | Graph coverage fix; zero eager forwards in its gate. |
| `aevonix-mia-131` to `-134` | `TF_GLM_CP_GRAPH_PAD` and `PARALLEL=5` | Rank agreement and graph counters; graphs reused across cache allocations; bounded row shapes; five-session admission for full GLM with CP=1. | Five-session gate: 320 suite identities and five populated 32K needle and 400-token concurrent-versus-solo comparisons. *Exact*. |
| `aevonix-mia-200-cp-graph-buckets` | `TF_GLM_CP_GRAPH_PAD=2`, `TF_GLM_CP_MULTI_GRAPH_CACHE=128` | Common row buckets and a 128-entry graph cache. | Mixed alone across stream counts; about 3 GiB more device memory per rank. |
| `aevonix-mia-201-cp-batch-exchange` | `TF_GLM_CP_BATCH_EXCHANGE` | Packs concurrent candidate, query and partial-result collectives; per-request kernel order and the rank-order merge are unchanged. | With patch 202, improved every measured multi-stream cell over the control in the one-pass v10 comparison. *Exact*. |
| `aevonix-mia-202-native-paged-cp` | `TF_GLM_CP_NATIVE_PAGED` | Addresses physical pages directly in FP8 cache writes, index selection and sparse attention. | Four-stream aggregate prose/code/structured 129.05/141.85/205.28 tok/s versus 109.92/112.69/156.89 for the control (one pass, 32K allocation). 168 native byte cases pass. |
| `aevonix-mia-203-batch-drafting` | `TF_GLM_DSPARK_BATCH_BLOCKS` | Batch-aware draft limits and drafter graphs. | Off in production: geometric mean 0.9974 of the native-page variant across nine multi-stream ratios. |
| `aevonix-mia-260` to `-266` | `TF_GLM_MULTI_PARK`, `TF_GLM_HOST_CACHE_GIB`, `TF_GLM_HOST_RESERVE_GIB`, `TF_GLM_DISK_*` | Prompt-cache tiers: a bounded RAM read-through tier, concurrent prompt parking to NVMe, cache identity and telemetry, idle host-pressure handling, retained restored prefixes, bounded paged scatter and launch-identity fingerprints. | Raw-byte transport; restored replies keep content and token identity. Resume times are in the README. Parking writes are synchronous and can pause sibling streams. |
| `aevonix-mia-280-vllm-metric-names` | none | Adds `vllm:num_requests_running`, `vllm:num_requests_waiting` and `vllm:kv_cache_usage_perc` with the same values as the TensorFold gauges. | Metrics only; the real `/metrics` routes pass. |
| `aevonix-mia-221` and `-223` | `TF_GLM_CP_VECTOR_MERGE`, `TF_GLM_CP_MERGE_EARLY_EXIT` | A resident integer candidate vector and an exact radix early exit for the context-parallel merge (TP4, top-k 2048, at most 16 rows). | Populated CP=1 decode +2.9%, +2.6% and +2.7% at 262,144, 524,288 and 1,048,112 prompt tokens on the qualification donor; CP=0 within 0.3%. *Exact*. |
| `aevonix-mia-235` and `-236` | `TF_GLM_MSA_HALF_HEADS`, `TF_GLM_MSA_SKIP_EMPTY_QK` | Omit unused output and QK head tiles in FP8 prompt attention with at most 16 local heads. | Cold prefill +3.0% to +4.0% (CP=1) and +2.4% to +3.5% (CP=0) on the donor; short decode within 0.3%. *Exact*: live-head accumulation order is unchanged. |

Not adopted: an optional earlier host cache and IPC collectives, and the screened kernel experiments that regressed
or gained under 1%.

## Build patches

| Patch | What it changes |
|---|---|
| `aevonix-mia-001-package-cuda-headers` | Copies every runtime `.h`, `.hpp` and `.cuh` file into the installed package after the wheel installs, and compares their bytes with the source. |
| `aevonix-mia-002-single-host-pcie-launch` | Adds the first single-host launcher to the build context. The image does not use it; `serve.sh` and `scripts/start-integrated.sh` are the measured launcher. |
| `aevonix-mia-127-build-context` | Excludes the clone's Git metadata and Python caches from the Docker context. |
| `aevonix-mia-135-recipe-runtime-pins` | Pins the measured NVIDIA PyTorch base image by digest and the server dependencies: `av==18.1.0`, `xgrammar==0.2.8`, `jsonschema==4.26.0`, `transformers==5.18.0`, `tokenizers==0.23.1`, `safetensors==0.8.0`. |

## Mia's AI Lab patches

These 106 patches are Mia's AI Lab's, from her
[full GLM-5.3 recipe](https://github.com/MiaAI-Lab/GLM-5.3-EXL3-3x-DGX-Sparks-TensorFold) at `885f5c8`, ported to
TensorFold v0.6.5 and rebased to v0.6.6. Her repository describes each one; [the original port notes](PORT-v0.6.5.md)
give each patch's donor SHA256, its v0.6.5 port status and the files it touches. The [rebase notes](PORT-v0.6.6.md)
record the current patch hashes that changed.

| Patches | Area |
|---|---|
| 0001-0068 (64 applied) | Her GLM-5.3-Flash recipe's v1.4 base: EXL3 prompt kernels, FP8 and 4-bit dense layers, vision, copy drafts, decode rounds and kernels, FP8 KV, tool calls, prompt replay and reuse, metrics, multi-request serving and TP-N support. 0023, 0037, 0058 and 0059 are already in TensorFold v0.6.5. |
| 0100-0104 | Full GLM-5.3 (`glm_moe_dsa`) on the GLM CUDA engine: layout, weights, DSA, forward pass and engine. |
| 0105-0111 | Full-model prefill, prompt experts (drowzeys' kernels with a deterministic pairs mode), row split, Mia's prompt-expert and sparse-attention kernels, the MTP cost chain and 4-bit tiles. |
| 0112, 0113, 0118, 0120, 0129, 0131, 0135, 0141 | Context parallelism (`CP=1`): caches, the context-parallel forward pass, graphs, short-prompt selection, prompt pipelining and KV gathers. |
| 0114, 0116, 0117, 0123, 0125 | The DSpark drafter, draft costs, its sampling filter, draft dumps and the host Markov path. |
| 0115, 0133, 0137 | FP4 and FP4X KV formats. |
| 0119, 0121, 0122, 0124, 0126-0128, 0130, 0132, 0134, 0136, 0138-0140 | Calibration, graph checks, serial stop, memory traces, MoE overlap, expert prefetch, multi-request verify and serving, the prompt disk cache, 3K prompt chunks, multi-request kernels and graphs, and hybrid copy drafts. |
