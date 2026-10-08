# Port of the original full GLM-5.3 patches to TensorFold v0.6.5

This document records the original v0.6.5 port. The table's hashes identify Mia's original files, and its status
and release-tree references describe that port. See [Rebase to v0.6.6](PORT-v0.6.6.md) for the current base,
regenerated patch hashes and exact tree comparison.

Mia's AI Lab's [full GLM-5.3 recipe](https://github.com/MiaAI-Lab/GLM-5.3-EXL3-3x-DGX-Sparks-TensorFold) at commit
`885f5c8` carries 110 patches for TensorFold v0.6.0: 0001-0068 are her GLM-5.3-Flash recipe's v1.4 patches and
0100-0141 add full GLM-5.3. The original port applied them sequentially to TensorFold v0.6.5
(`609ca419abecebdc5a059498a613680bd3aa847f`), reusing the compatibility resolutions of our
[GLM-5.3-Flash recipe](https://github.com/Aevonix/GLM-5.3-Flash-EXL3-4x-RTX-PRO-6000-TensorFold) where they apply.

Of the 110 original patches, 32 apply unchanged, 74 are adapted and 4 are left out because
TensorFold v0.6.5 already contains their change. The 106 applied files are in `patches/miaai-lab/`, each with its own
first lines; the SHA256 column identifies the original file in her repository, so every port can be compared with its
source. An unchanged classification requires both zero-offset, zero-fuzz application of the original bytes and
equality with the release tree. Adapted patches were merged sequentially, regenerated and replayed strictly.

| Original patch | Original SHA256 at 885f5c8 | Status | Port note |
|---|---|---|---|
| 0001-glm-exl3-prompt-experts.patch | `edc86d34101f5f7299b702d9d943509088cf53932bc4982f33fa62559e6a601d` | unchanged | The original bytes apply with zero fuzz and offset and reproduce the release tree. |
| 0002-glm-dense-fp8.patch | `179049d9fe96084e62892d0aa07245061a867dac80d87fb690c636d542f73e54` | adapted | The Flash port's v0.6.2 version applies there unchanged; regenerated here for the original v0.6.0 series and its exact target context. |
| 0003-glm-vision.patch | `9579dec80f712e2f34c095ea0ca639d1a93d920c675b6df712b5671dfb91cc5c` | adapted | Merge GLM image/video frontend with upstream tool-result images (4825c01), video input (6091427), visual-token budgets (362610f), and clear_thinking (ad15127). Keep GLM frame sampling and recipe media byte limits. |
| 0004-glm-prompt-kernels.patch | `8006ee8ff42433a813a80d2209b90a6191b4aba255d549406f75fda13d68d917` | adapted | Rebased hunk context/line positions; three-way merge preserves both changes. |
| 0005-glm-dense-q4.patch | `da13106efa1e2d4ef77e289f60ceba1bcbe1139cabec1595cac1eb6fa73bf91f` | adapted | The Flash port's v0.6.2 version applies there unchanged; regenerated here for the original v0.6.0 series and its exact target context. |
| 0006-cuda-roce-allgather.patch | `3ea885f9f592d698e4c481f1f4a74d6568aa5574aa16aac767328a5b374051b2` | adapted | Rebased hunk context/line positions; three-way merge preserves both changes. |
| 0007-glm-copy-drafts.patch | `be6e0d7b2d1d411a66d759084c798ce4759cf15318d0adc2b1351b065f58115c` | adapted | The Flash port's v0.6.2 version applies there unchanged; regenerated here for the original v0.6.0 series and its exact target context. |
| 0008-glm-prompt-grid.patch | `0aa9359a0ab36bbacf6d517fce985e2135b77e3c51324c7655b724b499d0a214` | adapted | The Flash port's v0.6.2 version applies there unchanged; regenerated here for the original v0.6.0 series and its exact target context. |
| 0009-glm-prefill-kernels.patch | `d2aa05b438b09e8147f58d76b986627f6aa78426b8a8a4ee6be81d34d7b12b91` | adapted | The Flash port's v0.6.2 version applies there unchanged; regenerated here for the original v0.6.0 series and its exact target context. |
| 0010-glm-hc-split.patch | `f0d39247e8934f40c66986519b691f1b19d73de7e17829c9eb061cb8c6302756` | adapted | Keep prompt row exchanges, upstream communicator protocol/dtypes, timeout_s and rendezvous key (c3d92bb). Final asymmetric NCCL compatibility is retained here by aevonix-mia-120. |
| 0011-glm-draft-sim.patch | `9a79a475446c6afb71b6a6831037f6366df2faaef2400727e82f3638ff59f1b9` | adapted | The Flash port's v0.6.2 version applies there unchanged; regenerated here for the original v0.6.0 series and its exact target context. |
| 0012-glm-kda-chunked.patch | `907f1a9d44021ef7fb2bb25ac66ed0a0fb61365ad8df705d34eb22aa2856cb30` | adapted | The Flash port's v0.6.2 version applies there unchanged; regenerated here for the original v0.6.0 series and its exact target context. |
| 0013-glm-decode-rounds.patch | `fc8bae87cc0ac5849792fa4e2b9eb4ab79499a6e18618feea3914d463d5abbca` | adapted | Rebased hunk context/line positions; three-way merge preserves both changes. |
| 0014-glm-kda-chunked-gb10.patch | `fded3f2cf26fadf827117620a5264557ef1afd94202d95d3d93d7814ab97394d` | unchanged | The original bytes apply with zero fuzz and offset and reproduce the release tree. |
| 0015-glm-shared-prefix.patch | `079c9a59fe89724bad8e0bfcdf90d0fc1fb79285c941886b842e7119e869e7b0` | adapted | The Flash port's v0.6.2 version applies there unchanged; regenerated here for the original v0.6.0 series and its exact target context. |
| 0016-glm-decode-kernels.patch | `12c398eaedcbed228ed6aa4919b444fff4d35634c4684e7aa55b1478f26cc0c9` | adapted | The Flash port's v0.6.2 version applies there unchanged; regenerated here for the original v0.6.0 series and its exact target context. |
| 0017-glm-overlap-priority.patch | `c0a0698de741c727c4e639b38adb2a53a7ab040c1f0feebd2d57f59f5cf621e3` | unchanged | The original bytes apply with zero fuzz and offset and reproduce the release tree. |
| 0018-glm-noise-policies.patch | `6592e008e0a1660e1d80af179250ec7230fddf4318b5d8c74ca6f865765bca04` | unchanged | The original bytes apply with zero fuzz and offset and reproduce the release tree. |
| 0019-glm-decode-kernels2.patch | `d26cab4240e16ad3f088393d38bf95081df4e643306086187c5083d0ab207746` | adapted | The Flash port's v0.6.2 version applies there unchanged; regenerated here for the original v0.6.0 series and its exact target context. |
| 0020-glm-prompt-experts-order.patch | `47a3ea494d513fd1940d39a6222faa58eb7e920444c9edfa3747bdb408cce6f2` | unchanged | The original bytes apply with zero fuzz and offset and reproduce the release tree. |
| 0021-glm-dflash-policy-env.patch | `64cd15d9dbf6fefa46c8688b245c4b89d8120e9753fd5e7ba9fde51e878c3b00` | unchanged | The original bytes apply with zero fuzz and offset and reproduce the release tree. |
| 0022-glm-overlap-normal-priority.patch | `ba6ec21bf892abfbc8126dc4339512236e8a14ea6fa27feafc74f0d73b707bf2` | unchanged | The original bytes apply with zero fuzz and offset and reproduce the release tree. |
| 0023-server-effort-max.patch | `bf03efd3f3acac5cf08c96715640143316da9ec844d3255f94425c2906dbc713` | dropped-upstream | Upstream b3d8733 supplies max effort; retain nearest named effort mapping from 26a95a6. |
| 0024-glm-prompt-select-rows.patch | `27d33a55af4970ce060e855e2c80d081c37ae10adbe409a99053c05fddae2364` | unchanged | The original bytes apply with zero fuzz and offset and reproduce the release tree. |
| 0025-glm-dflash2-ring.patch | `a866ded3cf5ddf4403b3dbda3ab659f03b36e05261f3b5656ecfb0ea4631cc27` | unchanged | The original bytes apply with zero fuzz and offset and reproduce the release tree. |
| 0026-glm-multi-kda.patch | `fc198453905cbd66c504c2f87affa571436aa3334f19f8a22225787976d8a056` | adapted | The Flash port's v0.6.2 version applies there unchanged; regenerated here for the original v0.6.0 series and its exact target context. |
| 0027-glm-multi-dflash2.patch | `83c23b768022f8c6c75e9e21a5ddbfac969c46c875f26cad65e64a83de83f741` | unchanged | The original bytes apply with zero fuzz and offset and reproduce the release tree. |
| 0028-glm-lean-prompt-scratch.patch | `b5b47ca6a0003b4b0f2bdda18f39a365b3113c8b13ae6c0019d256b8bb47d135` | adapted | Rebased hunk context/line positions; three-way merge preserves both changes. |
| 0029-glm-multi-dsa.patch | `9d87b5458a81ce345404d92e20c20ae66e6dbe3930c92c68fb478701795e67a7` | adapted | The Flash port's v0.6.2 version applies there unchanged; regenerated here for the original v0.6.0 series and its exact target context. |
| 0030-glm-multi-stream-engine.patch | `86669c866545a136ca68c536f16e9304a305d6e0672dc4f66db29410498b96c1` | adapted | Rebased hunk context/line positions; three-way merge preserves both changes. |
| 0031-glm-decode-index-regs.patch | `d0300cc64041b3e7647b3b5cc04620e18bea7fdac50b8fecba92023608391d16` | unchanged | The original bytes apply with zero fuzz and offset and reproduce the release tree. |
| 0032-glm-code-copy-drafts.patch | `ba6b20cb2e9f7bb2653c6c0d1ce1d46f5d04d7d2b24467d662043b1f4b6349fd` | adapted | The Flash port's v0.6.2 version applies there unchanged; regenerated here for the original v0.6.0 series and its exact target context. |
| 0033-glm-prefill-overlap2.patch | `dcd892ae7a17ddc33f54b4bcd1e7d25852c0d585c21f19c7862d7f6a8a9e6c6b` | adapted | The Flash port's v0.6.2 version applies there unchanged; regenerated here for the original v0.6.0 series and its exact target context. |
| 0034-cuda-nucleus-union.patch | `c38c65a26382c58b727a061657b84677fb83843f72ccc45352c351e1ad17bee9` | unchanged | The original bytes apply with zero fuzz and offset and reproduce the release tree. |
| 0035-glm-multi-rounds.patch | `36e766827023a05e5da64563ca3a8bcf95e7bbe2a0320f6132cc17263ff6583d` | adapted | The Flash port's v0.6.2 version applies there unchanged; regenerated here for the original v0.6.0 series and its exact target context. |
| 0036-glm-tool-calls.patch | `c82b7ebe94219969c11ddf59f90e11133527afc08f9d519c933bf4728ee5c95f` | adapted | Combine recipe tool-call streaming/history recovery with upstream clear_thinking (ad15127), stop-sequence reporting (e9fade0), and max_tokens-inside-thinking warning (bcb8f01). |
| 0037-cuda-tokenize.patch | `ad63e936baff5c088129c49f4ea0096564bf8318bfc29c748e240708879d0a2f` | dropped-upstream | 8f5e680 (integrated by 45325f7): CUDA token-id prompts, tokenize/detokenize aliases, special-token and generation flags, vocabulary validation; upstream also supports return_token_strs. Only redundant unused helper/constants remained. |
| 0038-glm-kv-fp8.patch | `3b017fff636eb917d34be86dbecf9467945d950f66b90c2fcc8f4cda523c42e1` | adapted | Rebased hunk context/line positions; three-way merge preserves both changes. |
| 0039-glm-kda-chunked-kernel.patch | `2c41c2c8a3b1b0e3c83b25860ee52b8883432d0260a7f743b9be9d9d09b2c99f` | adapted | The Flash port's v0.6.2 version applies there unchanged; regenerated here for the original v0.6.0 series and its exact target context. |
| 0040-glm-parallel-deadlocks.patch | `7702b7f7da3edfd3958b8152088ae8b6c11019934dfc22228258003f9aef51c6` | adapted | The Flash port's v0.6.2 version applies there unchanged; regenerated here for the original v0.6.0 series and its exact target context. |
| 0041-glm-parallel-ring-base.patch | `c9fb854b44369f7b8574c1e7b9f45ed688e75115d03563269dc9f9bf01aae7b2` | unchanged | The original bytes apply with zero fuzz and offset and reproduce the release tree. |
| 0042-glm-prompt-replay.patch | `22eeaa840c62b870e5a43c89d887ac70284796af46a11bc910fd5a97561fc261` | adapted | The Flash port's v0.6.2 version applies there unchanged; regenerated here for the original v0.6.0 series and its exact target context. |
| 0043-glm-visible-pools.patch | `0b58a80c28ed8eabf8239f8aab21c3c0120444ff1d81aba2a22c9b25da07ba80` | unchanged | The original bytes apply with zero fuzz and offset and reproduce the release tree. |
| 0044-cuda-context-errors.patch | `8a323aa49770e6a20775011fcb15ff9537e0d3121b7061de5e2f95a78fe0a06d` | adapted | Upstream 8f5e680 already supplies text context errors; retain the GLM vision context_length_exceeded wording added by this patch. |
| 0045-cuda-metrics.patch | `c5019c67de449695e9559e858698e22475775e25afd25c74cf41985f81d6ad8d` | adapted | Keep live GLM pool/health metrics and snapshot guards alongside upstream per-request decode counters (c9259c3), process footprint (0a57d1f), and HTTP/auth counters (bcb8f01). |
| 0046-glm-l2-prefetch.patch | `7a5c8a1c1b855f4aca3def0f604922abbfc2b681f73c346a105ce78008d67fde` | adapted | The Flash port's v0.6.2 version applies there unchanged; regenerated here for the original v0.6.0 series and its exact target context. |
| 0047-glm-exl3-decode-loads.patch | `387c5d55584d698c1c66387d0b51efd09c06bfc0b4500d567e2c5d0be8189845` | unchanged | The original bytes apply with zero fuzz and offset and reproduce the release tree. |
| 0048-glm-timing-tokens.patch | `a5cf2056c04ae0ddc0e0ef5d2893f6d50769498981550c983d121e6ca88eca93` | unchanged | The original bytes apply with zero fuzz and offset and reproduce the release tree. |
| 0049-glm-multi-prefill.patch | `f296f74cb2d1591b3042d216f3d43c85e0018ccb1b6cdad94905144a434b2f58` | adapted | The Flash port's v0.6.2 version applies there unchanged; regenerated here for the original v0.6.0 series and its exact target context. |
| 0050-glm-many-media.patch | `031f62cdaf7974a9f0fbf01cd937a0b63a7063b0be716505b704dcfad1d049f8` | adapted | Keep custom GLM image/video loaders and 96 MiB request limit; use upstream chunked-body reader (dc8e9eb) with an explicit limit and preserve configurable visual-token budgets. |
| 0051-glm-tool-history-recovery.patch | `38f6cb6ec9b3fc59f105479105dab2476f65e17cd35075059ccf258904735550` | adapted | Rebased hunk context/line positions; three-way merge preserves both changes. |
| 0052-cuda-roce-startup.patch | `e6d8ec3a1d52ab85973bf883a7481380c52e5c7b9f09ea19d238bcd2179d1c45` | adapted | The Flash port's v0.6.2 version applies there unchanged; regenerated here for the original v0.6.0 series and its exact target context. |
| 0053-glm-whole-tool-calls.patch | `35460fb7ec36c2a821054b1837a506ed171ab5418cf056de36cd4be5b4132b85` | adapted | Rebased hunk context/line positions; three-way merge preserves both changes. |
| 0054-glm-image-prompt-reuse.patch | `4b15494e28e0979ef0eb581530abc399e6d2e697ea4bbc287a6572c2ab2b985c` | unchanged | The original bytes apply with zero fuzz and offset and reproduce the release tree. |
| 0055-glm-open-tool-calls.patch | `b375f0a951a2a48738fd9a2060fd82151338276afa08ad7351ce2ce489c392d8` | adapted | Keep upstream raw text for stop-sequence reporting and recipe EOS tool-call closure. |
| 0056-glm-tool-result-media.patch | `9aed928badbbca40bdc5e59ea2167ec1141b8b87b2ea15e1f0bf8bf5bafe02d4` | adapted | Retain upstream tool-image roles and visual budgets; add recipe media ordering markers and tool-video support. |
| 0057-server-thinking-alias.patch | `840f334ac02fddc3f1250ec4a305ae638b8d7dd277e53907a4f288b64c0797bf` | adapted | Upstream ad15127 supplies thinking aliases; retain recipe bounded ignored-value logging and explicit-switch precedence. |
| 0058-server-client-gone-poll.patch | `d6449aec4c6b6b6aa1b15a3d1ab8d1a7baa7ea374db6a59d06b0ff8443c8cafa` | dropped-upstream | Upstream 7a1c776 already contains the descriptor-safe poll implementation. |
| 0059-server-refused-bodies.patch | `e11c12b4fdcaf7ebd4808f4b7df27fffb44408d8c49c33576d847a33d43b589b` | dropped-upstream | Upstream ced6139/dc8e9eb drain refused bodies with shared chunked framing and connection closure; retain 96 MiB GLM limit. |
| 0060-glm-keep-thinking.patch | `83d12b2ee9889bfdb995c391bcf87667f8297e267c47de8677a098cf743c6ab4` | adapted | Preserve recipe clear_thinking=False default and explicit request override; remove duplicated upstream wrapper state. |
| 0061-server-smooth-stream.patch | `825dadc22e223e242fbd145c50772467259dd68c9f6de80635aac050eb0d0c90` | adapted | Rebased sequentially; adjusted hunk positions/context. |
| 0062-glm-sliced-fill.patch | `2b56aa77390d0f21fce8bc8655ea4bc902c1caf3a923e3c3056263f7fb139455` | adapted | Rebased sequentially; adjusted hunk positions/context. |
| 0063-glm-kept-cap-superseded-first.patch | `e7956307fce055be0efa8764e034165153c85e9fb3a3ba522fd527e7c3efd8cd` | unchanged | The original bytes apply with zero fuzz and offset and reproduce the release tree. |
| 0064-glm-split-connect-early.patch | `a1f3ddd16627f6b330c3655508463cddbeedb1ed7d9107ff13b4455335219c3e` | adapted | Rebased sequentially; adjusted hunk positions/context. |
| 0065-glm-rank-checks.patch | `1d896beb6e8f8b8c962e99626e7522ef0fb9b4687214fe77c612b798d8966e7e` | unchanged | The original bytes apply with zero fuzz and offset and reproduce the release tree. |
| 0066-glm-tp-n.patch | `5f879e7b85e0a0aa52f36fb2c94a34cec0a21f2c3bac321254944a013c5b4381` | adapted | Reuses the Flash port's TP-N open_comm(world=world) integration; retain early split connection warm-up from 0064 and pass world to weight loading. |
| 0067-glm-tp3-split-pad.patch | `babaaef3cc3da9b9d0a33522afebfb68ae7e3be0c43f39e5c87b95eb6c851839` | adapted | The Flash port's v0.6.2 version applies there unchanged; regenerated here for the original v0.6.0 series and its exact target context. |
| 0068-glm-tpn-split-buffer-rows.patch | `1f4d14cd8ff3151f8956b218e30192a9b252e1a7574d9915b6de48ecdb710984` | adapted | The Flash port's v0.6.2 version applies there unchanged; regenerated here for the original v0.6.0 series and its exact target context. |
| 0100-glm-full-layout.patch | `9e7c3c33b4ed7d35ce8d87dfcd4daf88067cf625d1bd861da14413a734148d66` | unchanged | The original bytes apply with zero fuzz and offset and reproduce the release tree. |
| 0101-glm-full-weights.patch | `fa640d513842d565d14c90e91d8a7351bb2b4815be45e72e771d7db95197fa3f` | adapted | Keeps the Flash port's EXL3 codebook metadata alongside full GLM mixed-width layout and weight loader. |
| 0102-glm-full-dsa.patch | `546e7640012563b199301dbadf923aaf414332aea07fa293bed0c46445ef61a8` | unchanged | The original bytes apply with zero fuzz and offset and reproduce the release tree. |
| 0103-glm-full-forward.patch | `d8c6dfdbeb8c522af230a1a2eb1b29ed3552d7de7d33b50d2cac9107b55db59b` | adapted | Allocate full GLM mixed-width scratch separately from Flash universal/legacy EXL3 routes; retain both Flash paths. |
| 0104-glm-full-engine.patch | `2a53b8ed76f79031245c108447508e98276af9d5628eb232dcfd857cbd285a54` | adapted | Rebased sequentially; adjusted hunk positions/context. |
| 0105-glm-full-prefill.patch | `29f9d27741419635e8f4873972293932c20639a3d3dbf8e79a2ad3f736c5ab0f` | adapted | Retain upstream shared-memory opt-in including static storage/device-limit checks; add full GLM prefill support. |
| 0106-glm-full-prompt-experts.patch | `e2df1addc989d48ce23d14f6c5f8dfa00652b65cac1b28f0918e3c3e49bead57` | adapted | Rebased sequentially; adjusted hunk positions/context. |
| 0107-glm-full-row-split.patch | `a64154e7ae900d3f1079d8b4e8775d438f0951ad7426db86391f82033797aea1` | adapted | Rebased sequentially; adjusted hunk positions/context. |
| 0108-glm-full-mia-prompt-experts.patch | `f981630704e16068cd6425c1e4e364078251f7ce8ac9c334cc181bfb5bf6ed36` | adapted | Rebased sequentially; adjusted hunk positions/context. |
| 0109-glm-full-mtp-cost-chain.patch | `e6e1033e7ada0a7807138aa4b8d03cd3e4a04d960795da948e5aff268c664539` | unchanged | The original bytes apply with zero fuzz and offset and reproduce the release tree. |
| 0110-glm-full-mia-sparse-attention.patch | `596e28790b111c89d925a318698c8daed34b7f6c864f1920555321509e5f8d0a` | adapted | Rebased sequentially; adjusted hunk positions/context. |
| 0111-glm-full-q4-tiles.patch | `d513f46b6ec1c0decedcedd184532aaab15a5e70fad7d6d83567fc6a30dfbd51` | unchanged | The original bytes apply with zero fuzz and offset and reproduce the release tree. |
| 0112-glm-full-cp-caches.patch | `c5a5039545fb6ca839b31f12a8b05a8e68ea1e58007f5794c2ae9ae809ead387` | adapted | Rebased sequentially; adjusted hunk positions/context. |
| 0113-glm-full-context-parallel.patch | `5eee3b0c27c44b4b7f2065f0812ea207c6f3e7db28b7d482e5af374fb69a5c6e` | adapted | Rebased sequentially; adjusted hunk positions/context. |
| 0114-glm-full-dspark.patch | `fb5df78c674a2147487d5b5e8baa5a32dd44d1642f346c4b6e82d7ba43a03188` | adapted | Rebased sequentially; adjusted hunk positions/context. |
| 0115-glm-full-kv-fp4.patch | `3d048924f487efd1473870c915d9e6808c0a3ce13215d626606faa1ac7760c66` | adapted | Rebased sequentially; adjusted hunk positions/context. |
| 0116-glm-full-draft-costs.patch | `61f6cecb564c2e625fb23706ddeefa89388866c2eaab7dbff6d4c7874afd8998` | adapted | Rebased sequentially; adjusted hunk positions/context. |
| 0117-glm-full-dspark-sampling.patch | `4ce55e938cc4301c76ea8664b4f4f7f7e09ae47467a617df51ee2a3eb1d2adf0` | unchanged | The original bytes apply with zero fuzz and offset and reproduce the release tree. |
| 0118-glm-full-cp-graphs.patch | `8c8a4e6a05aaf9e95e96a237f89896fe531803353964c049b21f16a38eb992c8` | adapted | Rebased sequentially; adjusted hunk positions/context. |
| 0119-glm-full-text-calibration.patch | `9698af4f735e4311d5011bede4e328f3843383fcb88a3fa443c7629d758eafb7` | unchanged | The original bytes apply with zero fuzz and offset and reproduce the release tree. |
| 0120-glm-full-cp-short-select.patch | `f86b8849d8e04a73c51c13579f7c665ecc4ba521d729f9944c9e756c782b13b9` | adapted | Rebased sequentially; adjusted hunk positions/context. |
| 0121-glm-full-graph-roce-check.patch | `c155b259f556440e6ece7586dd45dc9e17202eb1fe63e1e8af7983ffede26305` | unchanged | The original bytes apply with zero fuzz and offset and reproduce the release tree. |
| 0122-glm-full-serial-stop.patch | `feabe46d84c6040d15d1b11e53333eb96b7128263f350a3be74a1fa6bedf827a` | adapted | Rebased sequentially; adjusted hunk positions/context. |
| 0123-glm-full-dspark-dump.patch | `233732d2f3ca52f8c41774b5a2c786ab9eb44b811fccc58441553efae0c957be` | unchanged | The original bytes apply with zero fuzz and offset and reproduce the release tree. |
| 0124-glm-full-mem-trace.patch | `d19d8865577b56b3c71cd8c453692785da7206461d8cbdfef79c0e5112bc7187` | unchanged | The original bytes apply with zero fuzz and offset and reproduce the release tree. |
| 0125-glm-full-dspark-host-markov.patch | `4a715aaf12edf8bf4384803700d96aa32a93378b628f7dea404b42ed45f535e7` | unchanged | The original bytes apply with zero fuzz and offset and reproduce the release tree. |
| 0126-glm-full-calibration-windows.patch | `ac3f27346357ef7ebd3a407b4eee4ed5e68fb1bdf68d361725f2e11ad9236331` | unchanged | The original bytes apply with zero fuzz and offset and reproduce the release tree. |
| 0127-glm-full-moe-overlap.patch | `3895d2c1fc45fb918b634d8d9a534c3f4e5b6e9cfe55f1fac8d01df7cf13fc1f` | adapted | Rebased sequentially; adjusted hunk positions/context. |
| 0128-glm-full-expert-prefetch.patch | `18ad444c55b7d371a0aaf38ed11b7b78c83b9fc0f6904cc746e70b0c6c26e384` | adapted | Rebased sequentially; adjusted hunk positions/context. |
| 0129-glm-full-cp-prompt-msa.patch | `69840c34904f362df06ae63722fd6cbe3614145df2e81ffb5752889dd4ae1a41` | adapted | Rebased sequentially; adjusted hunk positions/context. |
| 0130-glm-full-multi-verify.patch | `a8aa627af74e37797b8e2971892bbac22cabcc1208c0e311e59155da2f55ab30` | adapted | Rebased sequentially; adjusted hunk positions/context. |
| 0131-glm-full-cp-prompt-pipe.patch | `8dd8419dd29cfd3c230bf3df15833ecd6e6cb490752b2eedeabd35240849974f` | adapted | Rebased sequentially; adjusted hunk positions/context. |
| 0132-glm-full-prompt-disk-cache.patch | `f81fd96fe8650952f159a04d9ac4c579e8b5d8aa56e254ea8c2ee297ef3e7ff9` | adapted | Read disk-cache selector from the already received upstream decision-aware header; avoid a second rank broadcast. |
| 0133-glm-full-kv-fp4x.patch | `db1772f7fd9f04442bf77a24f39de2a380b532b33bbcd82a0a1606b3ceee1eaf` | adapted | Rebased sequentially; adjusted hunk positions/context. |
| 0134-glm-full-multi-serve.patch | `a2292a0e1a607c7a26a308e6ec044e749a34299cfb798835619fe21029183ef0` | adapted | Rebased sequentially; adjusted hunk positions/context. |
| 0135-glm-full-cp-prompt-raw-q.patch | `4b137fac4121d97296db37bc75a1cc6e499b3b68cca174fea61802b2b7f10055` | adapted | Rebased sequentially; adjusted hunk positions/context. |
| 0136-glm-full-chunk3k.patch | `b33af5366c75200998fd472a193ebe02c4df250317ef75e47050a3ff2bf00ee9` | adapted | Use recipe 16-bit grouping and global-memory fallback for 3K chunks; replaces upstream int grouping. Device shared-memory limit remains checked. |
| 0137-glm-full-kv-fp4x-fix.patch | `f1f1e966dba580df6375e0de6173dcaa9f240abd88f6a606f22c0a2ddfb1938c` | unchanged | The original bytes apply with zero fuzz and offset and reproduce the release tree. |
| 0138-glm-full-multi-kernels.patch | `dec0a2bf8d22e49096a2c01d6487572ca9718e109177b0d11730ce663ba61c3f` | unchanged | The original bytes apply with zero fuzz and offset and reproduce the release tree. |
| 0139-glm-full-multi-graphs.patch | `4333b5eb5cfeffa3ed95f58eed8fd3a14db2a47101b808416c70e3458ab1d764` | adapted | Rebased sequentially; adjusted hunk positions/context. |
| 0140-glm-full-copy-hybrid.patch | `95e8c0928ac6681d25db592b0cf9e6c1bcdf15cd035ba58a2f0c451b4aa2276a` | adapted | Rebased sequentially; adjusted hunk positions/context. |
| 0141-glm-full-cp-kv-gather.patch | `d714110346eee06de2bcd77b36dd804de1f499afb1118142dd08357951f9c429` | adapted | Rebased sequentially; adjusted hunk positions/context. |

## Files touched by each applied patch

- `0001-glm-exl3-prompt-experts.patch`: `tensorfold/families/glm5_next/cuda/exl3.cpp`, `tensorfold/families/glm5_next/cuda/exl3.cu`, `tensorfold/families/glm5_next/cuda/exl3_mm.py`
- `0002-glm-dense-fp8.patch`: `tensorfold/families/glm5_next/cuda/engine.py`, `tensorfold/families/glm5_next/cuda/forward.py`, `tensorfold/families/glm5_next/cuda/qmm.py`, `tensorfold/families/glm5_next/cuda/weights.py`
- `0003-glm-vision.patch`: `tensorfold/cuda/server.py`, `tensorfold/families/glm5_next/__init__.py`, `tensorfold/families/glm5_next/cuda/app.py`, `tensorfold/families/glm5_next/cuda/decode.py`, `tensorfold/families/glm5_next/cuda/engine.py`, `tensorfold/families/glm5_next/cuda/forward.py`, `tensorfold/serve_options.py`, `tensorfold/server/prompts.py`, `tensorfold/vision/glm.py`, `tensorfold/vision/videos.py`
- `0004-glm-prompt-kernels.patch`: `tensorfold/cuda/experts.cpp`, `tensorfold/cuda/experts.py`, `tensorfold/cuda/geometry.py`, `tensorfold/families/glm5_next/cuda/engine.py`, `tensorfold/families/glm5_next/cuda/exl3.cpp`, `tensorfold/families/glm5_next/cuda/exl3.cu`, `tensorfold/families/glm5_next/cuda/exl3_mm.py`, `tensorfold/families/glm5_next/cuda/forward.py`, `tensorfold/families/glm5_next/cuda/glue.py`, `tensorfold/families/glm5_next/cuda/latent.py`, `tensorfold/families/glm5_next/cuda/qmm.py`, `tensorfold/vision/glm.py`
- `0005-glm-dense-q4.patch`: `tensorfold/families/glm5_next/cuda/engine.py`, `tensorfold/families/glm5_next/cuda/qmm.py`, `tensorfold/families/glm5_next/cuda/weights.py`
- `0006-cuda-roce-allgather.patch`: `tensorfold/cuda/roce.cpp`, `tensorfold/cuda/roce.cu`, `tensorfold/cuda/roce.py`, `tensorfold/cuda/roce_proxy.c`, `tensorfold/families/glm5_next/cuda/engine.py`
- `0007-glm-copy-drafts.patch`: `tensorfold/families/glm5_next/cuda/copy_drafts.py`, `tensorfold/families/glm5_next/cuda/decode.py`, `tensorfold/families/glm5_next/cuda/drafter_choice.py`, `tensorfold/families/glm5_next/cuda/engine.py`
- `0008-glm-prompt-grid.patch`: `tensorfold/families/glm5_next/cuda/decode.py`, `tensorfold/families/glm5_next/cuda/engine.py`, `tensorfold/families/glm5_next/cuda/forward.py`
- `0009-glm-prefill-kernels.patch`: `tensorfold/families/glm5_next/cuda/exl3.cpp`, `tensorfold/families/glm5_next/cuda/exl3.cu`, `tensorfold/families/glm5_next/cuda/exl3_mm.py`, `tensorfold/families/glm5_next/cuda/forward.py`, `tensorfold/families/glm5_next/cuda/glue.py`, `tensorfold/families/glm5_next/cuda/latent.py`, `tensorfold/families/glm5_next/cuda/sparse.py`
- `0010-glm-hc-split.patch`: `tensorfold/cuda/comm.py`, `tensorfold/families/glm5_next/cuda/decode.py`, `tensorfold/families/glm5_next/cuda/engine.py`, `tensorfold/families/glm5_next/cuda/forward.py`, `tensorfold/families/glm5_next/cuda/glue.py`, `tensorfold/families/glm5_next/cuda/hcsplit.py`
- `0011-glm-draft-sim.patch`: `tensorfold/families/glm5_next/cuda/dflash2.py`, `tensorfold/families/glm5_next/cuda/draft_dump.py`, `tensorfold/families/glm5_next/cuda/draft_sim.py`, `tensorfold/families/glm5_next/cuda/engine.py`, `tensorfold/families/glm5_next/cuda/qmm.py`, `tensorfold/families/glm5_next/cuda/weights.py`
- `0012-glm-kda-chunked.patch`: `tensorfold/families/glm5_next/cuda/forward.py`, `tensorfold/families/glm5_next/cuda/kda.py`, `tensorfold/families/glm5_next/cuda/kda_chunked.py`
- `0013-glm-decode-rounds.patch`: `tensorfold/cuda/geometry.py`, `tensorfold/families/glm5_next/cuda/copy_drafts.py`, `tensorfold/families/glm5_next/cuda/decode.py`, `tensorfold/families/glm5_next/cuda/dflash2.py`, `tensorfold/families/glm5_next/cuda/drafter_choice.py`, `tensorfold/families/glm5_next/cuda/engine.py`, `tensorfold/families/glm5_next/cuda/latent.py`, `tensorfold/families/glm5_next/cuda/qmm.py`, `tensorfold/families/glm5_next/cuda/weights.py`
- `0014-glm-kda-chunked-gb10.patch`: `tensorfold/families/glm5_next/cuda/kda_chunked.py`
- `0015-glm-shared-prefix.patch`: `tensorfold/families/glm5_next/cuda/decode.py`, `tensorfold/families/glm5_next/cuda/engine.py`
- `0016-glm-decode-kernels.patch`: `tensorfold/cuda/kernels/qmm.cpp`, `tensorfold/cuda/kernels/qmm.cu`, `tensorfold/cuda/kernels/qmm.py`, `tensorfold/families/glm5_next/cuda/decode.py`, `tensorfold/families/glm5_next/cuda/exl3.cpp`, `tensorfold/families/glm5_next/cuda/exl3.cu`, `tensorfold/families/glm5_next/cuda/exl3_mm.py`, `tensorfold/families/glm5_next/cuda/kda.py`, `tensorfold/families/glm5_next/cuda/qmm.py`
- `0017-glm-overlap-priority.patch`: `tensorfold/families/glm5_next/cuda/hcsplit.py`
- `0018-glm-noise-policies.patch`: `tensorfold/families/glm5_next/cuda/decode.py`, `tensorfold/families/glm5_next/cuda/dflash2.py`, `tensorfold/families/glm5_next/cuda/engine.py`
- `0019-glm-decode-kernels2.patch`: `tensorfold/cuda/kernels/qmm.cu`, `tensorfold/families/glm5_next/cuda/forward.py`, `tensorfold/families/glm5_next/cuda/glue.py`, `tensorfold/families/glm5_next/cuda/hc.cpp`, `tensorfold/families/glm5_next/cuda/hc.cu`, `tensorfold/families/glm5_next/cuda/latent.py`, `tensorfold/families/glm5_next/cuda/qmm.py`
- `0020-glm-prompt-experts-order.patch`: `tensorfold/families/glm5_next/cuda/exl3.cpp`, `tensorfold/families/glm5_next/cuda/exl3.cu`, `tensorfold/families/glm5_next/cuda/exl3_mm.py`
- `0021-glm-dflash-policy-env.patch`: `tensorfold/families/glm5_next/cuda/engine.py`
- `0022-glm-overlap-normal-priority.patch`: `tensorfold/families/glm5_next/cuda/hcsplit.py`
- `0024-glm-prompt-select-rows.patch`: `tensorfold/families/glm5_next/cuda/sparse.py`
- `0025-glm-dflash2-ring.patch`: `tensorfold/families/glm5_next/cuda/decode.py`
- `0026-glm-multi-kda.patch`: `tensorfold/families/glm5_next/cuda/forward.py`, `tensorfold/families/glm5_next/cuda/kda.cpp`, `tensorfold/families/glm5_next/cuda/kda.cu`, `tensorfold/families/glm5_next/cuda/kda.py`
- `0027-glm-multi-dflash2.patch`: `tensorfold/families/glm5_next/cuda/dflash2.py`, `tensorfold/families/glm5_next/cuda/dflash2_multi.py`
- `0028-glm-lean-prompt-scratch.patch`: `tensorfold/cuda/geometry.py`, `tensorfold/families/glm5_next/cuda/engine.py`, `tensorfold/families/glm5_next/cuda/forward.py`, `tensorfold/families/glm5_next/cuda/latent.py`
- `0029-glm-multi-dsa.patch`: `tensorfold/families/glm5_next/cuda/forward.py`, `tensorfold/families/glm5_next/cuda/latent.py`, `tensorfold/families/glm5_next/cuda/segments.py`, `tensorfold/families/glm5_next/cuda/sparse.py`
- `0030-glm-multi-stream-engine.patch`: `tensorfold/cuda/health.py`, `tensorfold/families/glm5_next/__init__.py`, `tensorfold/families/glm5_next/cuda/decode.py`, `tensorfold/families/glm5_next/cuda/engine.py`, `tensorfold/families/glm5_next/cuda/forward.py`, `tensorfold/families/glm5_next/cuda/multi.py`, `tensorfold/families/glm5_next/cuda/pool.py`, `tensorfold/families/glm5_next/cuda/verify.py`
- `0031-glm-decode-index-regs.patch`: `tensorfold/families/glm5_next/cuda/sparse.py`
- `0032-glm-code-copy-drafts.patch`: `tensorfold/families/glm5_next/cuda/copy_drafts.py`, `tensorfold/families/glm5_next/cuda/engine.py`, `tensorfold/families/glm5_next/cuda/multi.py`
- `0033-glm-prefill-overlap2.patch`: `tensorfold/families/glm5_next/cuda/forward.py`, `tensorfold/families/glm5_next/cuda/hcsplit.py`
- `0034-cuda-nucleus-union.patch`: `tensorfold/cuda/sampling.py`
- `0035-glm-multi-rounds.patch`: `tensorfold/families/glm5_next/cuda/decode.py`, `tensorfold/families/glm5_next/cuda/dflash2.py`, `tensorfold/families/glm5_next/cuda/engine.py`, `tensorfold/families/glm5_next/cuda/multi.py`, `tensorfold/families/glm5_next/cuda/multi_tune.py`, `tensorfold/families/glm5_next/cuda/verify.py`
- `0036-glm-tool-calls.patch`: `tensorfold/cuda/http.py`, `tensorfold/cuda/reply_text.py`, `tensorfold/cuda/server.py`, `tensorfold/engine/tool_draft.py`, `tensorfold/families/glm5_next/cuda/app.py`, `tensorfold/families/glm5_next/cuda/kept_reasoning.py`, `tensorfold/families/glm5_next/prompts.py`, `tensorfold/server/messages.py`, `tensorfold/tool_parameters.py`
- `0038-glm-kv-fp8.patch`: `tensorfold/cuda/geometry.py`, `tensorfold/families/glm5_next/cuda/decode.py`, `tensorfold/families/glm5_next/cuda/engine.py`, `tensorfold/families/glm5_next/cuda/forward.py`, `tensorfold/families/glm5_next/cuda/kv8.py`, `tensorfold/families/glm5_next/cuda/latent.py`, `tensorfold/families/glm5_next/cuda/multi.py`, `tensorfold/families/glm5_next/cuda/segments.py`, `tensorfold/families/glm5_next/cuda/sparse.py`, `tensorfold/families/glm5_next/cuda/verify.py`
- `0039-glm-kda-chunked-kernel.patch`: `tensorfold/families/glm5_next/cuda/engine.py`, `tensorfold/families/glm5_next/cuda/kda.py`, `tensorfold/families/glm5_next/cuda/kda_chunk.cpp`, `tensorfold/families/glm5_next/cuda/kda_chunk.cu`, `tensorfold/families/glm5_next/cuda/kda_chunked.py`
- `0040-glm-parallel-deadlocks.patch`: `tensorfold/cuda/roce.py`, `tensorfold/families/glm5_next/cuda/engine.py`, `tensorfold/families/glm5_next/cuda/multi.py`, `tensorfold/families/glm5_next/cuda/multi_tune.py`, `tensorfold/families/glm5_next/cuda/verify.py`
- `0041-glm-parallel-ring-base.patch`: `tensorfold/families/glm5_next/cuda/verify.py`
- `0042-glm-prompt-replay.patch`: `tensorfold/families/glm5_next/cuda/decode.py`, `tensorfold/families/glm5_next/cuda/engine.py`, `tensorfold/families/glm5_next/cuda/multi.py`
- `0043-glm-visible-pools.patch`: `tensorfold/families/glm5_next/cuda/sparse.py`
- `0044-cuda-context-errors.patch`: `tensorfold/vision/glm.py`
- `0045-cuda-metrics.patch`: `tensorfold/server/metrics.py`
- `0046-glm-l2-prefetch.patch`: `tensorfold/families/glm5_next/cuda/decode.py`, `tensorfold/families/glm5_next/cuda/forward.py`, `tensorfold/families/glm5_next/cuda/l2pf.cpp`, `tensorfold/families/glm5_next/cuda/l2pf.cu`, `tensorfold/families/glm5_next/cuda/l2pf.py`
- `0047-glm-exl3-decode-loads.patch`: `tensorfold/families/glm5_next/cuda/exl3.cpp`, `tensorfold/families/glm5_next/cuda/exl3.cu`, `tensorfold/families/glm5_next/cuda/exl3_mm.py`
- `0048-glm-timing-tokens.patch`: `tensorfold/families/glm5_next/cuda/multi.py`, `tensorfold/families/glm5_next/cuda/verify.py`
- `0049-glm-multi-prefill.patch`: `tensorfold/families/glm5_next/cuda/engine.py`, `tensorfold/families/glm5_next/cuda/forward.py`, `tensorfold/families/glm5_next/cuda/multi.py`, `tensorfold/families/glm5_next/cuda/multi_prefill.py`
- `0050-glm-many-media.patch`: `tensorfold/cuda/http.py`, `tensorfold/server/prompts.py`, `tensorfold/vision/glm.py`, `tensorfold/vision/images.py`
- `0051-glm-tool-history-recovery.patch`: `tensorfold/families/glm5_next/prompts.py`
- `0052-cuda-roce-startup.patch`: `tensorfold/cuda/roce.py`, `tensorfold/families/glm5_next/cuda/engine.py`
- `0053-glm-whole-tool-calls.patch`: `tensorfold/cuda/reply_text.py`, `tensorfold/cuda/server.py`
- `0054-glm-image-prompt-reuse.patch`: `tensorfold/families/glm5_next/cuda/multi.py`, `tensorfold/vision/glm.py`
- `0055-glm-open-tool-calls.patch`: `tensorfold/cuda/reply_text.py`, `tensorfold/cuda/server.py`
- `0056-glm-tool-result-media.patch`: `tensorfold/cuda/server.py`, `tensorfold/families/glm5_next/cuda/app.py`, `tensorfold/server/prompts.py`, `tensorfold/vision/glm.py`, `tensorfold/vision/images.py`
- `0057-server-thinking-alias.patch`: `tensorfold/server/request_options.py`
- `0060-glm-keep-thinking.patch`: `tensorfold/families/glm5_next/cuda/app.py`
- `0061-server-smooth-stream.patch`: `tensorfold/cuda/server.py`, `tensorfold/cuda/stream_pacing.py`
- `0062-glm-sliced-fill.patch`: `tensorfold/cuda/server.py`, `tensorfold/families/glm5_next/cuda/decode.py`, `tensorfold/families/glm5_next/cuda/engine.py`, `tensorfold/families/glm5_next/cuda/forward.py`, `tensorfold/families/glm5_next/cuda/multi.py`, `tensorfold/families/glm5_next/cuda/multi_prefill.py`, `tensorfold/families/glm5_next/cuda/sliced_fill.py`
- `0063-glm-kept-cap-superseded-first.patch`: `tensorfold/families/glm5_next/cuda/multi.py`
- `0064-glm-split-connect-early.patch`: `tensorfold/families/glm5_next/cuda/engine.py`
- `0065-glm-rank-checks.patch`: `tensorfold/families/glm5_next/cuda/multi.py`
- `0066-glm-tp-n.patch`: `tensorfold/cli.py`, `tensorfold/cli_args.py`, `tensorfold/cuda/comm.py`, `tensorfold/cuda/geometry.py`, `tensorfold/cuda/roce.py`, `tensorfold/cuda/roce_proxy.c`, `tensorfold/cuda/shares.py`, `tensorfold/families/glm5_next/__init__.py`, `tensorfold/families/glm5_next/cuda/decode.py`, `tensorfold/families/glm5_next/cuda/dflash2.py`, `tensorfold/families/glm5_next/cuda/engine.py`, `tensorfold/families/glm5_next/cuda/exl3.cu`, `tensorfold/families/glm5_next/cuda/exl3_mm.py`, `tensorfold/families/glm5_next/cuda/forward.py`, `tensorfold/families/glm5_next/cuda/glue.py`, `tensorfold/families/glm5_next/cuda/hcsplit.py`, `tensorfold/families/glm5_next/cuda/multi.py`, `tensorfold/families/glm5_next/cuda/split.py`, `tensorfold/families/glm5_next/cuda/tp.py`, `tensorfold/families/glm5_next/cuda/verify.py`, `tensorfold/families/glm5_next/cuda/weights.py`
- `0067-glm-tp3-split-pad.patch`: `tensorfold/families/glm5_next/cuda/decode.py`, `tensorfold/families/glm5_next/cuda/engine.py`, `tensorfold/families/glm5_next/cuda/forward.py`, `tensorfold/families/glm5_next/cuda/hcsplit.py`
- `0068-glm-tpn-split-buffer-rows.patch`: `tensorfold/families/glm5_next/cuda/decode.py`, `tensorfold/families/glm5_next/cuda/engine.py`, `tensorfold/families/glm5_next/cuda/hcsplit.py`
- `0100-glm-full-layout.patch`: `tensorfold/families/glm5_next/cuda/split.py`, `tensorfold/families/glm5_next/cuda/tp.py`
- `0101-glm-full-weights.patch`: `tensorfold/families/glm5_next/cuda/weights.py`
- `0102-glm-full-dsa.patch`: `tensorfold/families/glm5_next/cuda/dsa_full.py`, `tensorfold/families/glm5_next/cuda/latent.py`
- `0103-glm-full-forward.patch`: `tensorfold/families/glm5_next/cuda/decode.py`, `tensorfold/families/glm5_next/cuda/forward.py`, `tensorfold/families/glm5_next/cuda/graphs.py`, `tensorfold/families/glm5_next/cuda/mtp.py`
- `0104-glm-full-engine.patch`: `tensorfold/cuda/geometry.py`, `tensorfold/families/glm5_next/cuda/engine.py`, `tensorfold/families/glm_moe_dsa/__init__.py`
- `0105-glm-full-prefill.patch`: `tensorfold/cuda/exl3/experts.cpp`, `tensorfold/cuda/exl3/experts.cu`, `tensorfold/cuda/exl3/experts.py`, `tensorfold/cuda/exl3/experts_grouped.cuh`, `tensorfold/cuda/geometry.py`, `tensorfold/families/glm5_next/cuda/forward.py`
- `0106-glm-full-prompt-experts.patch`: `tensorfold/cuda/exl3/prompt_experts.cpp`, `tensorfold/cuda/exl3/prompt_experts.cu`, `tensorfold/cuda/exl3/prompt_experts.py`, `tensorfold/families/glm5_next/cuda/decode.py`, `tensorfold/families/glm5_next/cuda/forward.py`
- `0107-glm-full-row-split.patch`: `tensorfold/families/glm5_next/cuda/engine.py`, `tensorfold/families/glm5_next/cuda/forward.py`, `tensorfold/families/glm5_next/cuda/hcsplit.py`
- `0108-glm-full-mia-prompt-experts.patch`: `tensorfold/cuda/exl3/mpe.cpp`, `tensorfold/cuda/exl3/mpe.cu`, `tensorfold/cuda/exl3/mpe.py`, `tensorfold/families/glm5_next/cuda/forward.py`
- `0109-glm-full-mtp-cost-chain.patch`: `tensorfold/families/glm5_next/cuda/decode.py`, `tensorfold/families/glm5_next/cuda/drafter_choice.py`, `tensorfold/families/glm5_next/cuda/engine.py`
- `0110-glm-full-mia-sparse-attention.patch`: `tensorfold/families/glm5_next/cuda/decode.py`, `tensorfold/families/glm5_next/cuda/forward.py`, `tensorfold/families/glm5_next/cuda/msa.cpp`, `tensorfold/families/glm5_next/cuda/msa.cu`, `tensorfold/families/glm5_next/cuda/msa.py`
- `0111-glm-full-q4-tiles.patch`: `tensorfold/families/glm5_next/cuda/qmm.py`
- `0112-glm-full-cp-caches.patch`: `tensorfold/cuda/geometry.py`, `tensorfold/families/glm5_next/cuda/dsa_full.py`, `tensorfold/families/glm5_next/cuda/latent.py`
- `0113-glm-full-context-parallel.patch`: `tensorfold/families/glm5_next/cuda/dcp.py`, `tensorfold/families/glm5_next/cuda/engine.py`, `tensorfold/families/glm5_next/cuda/forward.py`
- `0114-glm-full-dspark.patch`: `tensorfold/families/glm5_next/cuda/decode.py`, `tensorfold/families/glm5_next/cuda/dspark.py`, `tensorfold/families/glm5_next/cuda/engine.py`, `tensorfold/families/glm_moe_dsa/__init__.py`
- `0115-glm-full-kv-fp4.patch`: `tensorfold/cuda/geometry.py`, `tensorfold/families/glm5_next/cuda/dcp.py`, `tensorfold/families/glm5_next/cuda/engine.py`, `tensorfold/families/glm5_next/cuda/kv8.py`, `tensorfold/families/glm5_next/cuda/latent.py`, `tensorfold/families/glm5_next/cuda/msa.cu`, `tensorfold/families/glm5_next/cuda/msa.py`
- `0116-glm-full-draft-costs.patch`: `tensorfold/families/glm5_next/cuda/engine.py`, `tensorfold/families/glm5_next/cuda/forward.py`, `tensorfold/families/glm5_next/cuda/latent.py`
- `0117-glm-full-dspark-sampling.patch`: `tensorfold/families/glm5_next/cuda/dspark.py`
- `0118-glm-full-cp-graphs.patch`: `tensorfold/families/glm5_next/cuda/dcp.py`, `tensorfold/families/glm5_next/cuda/decode.py`, `tensorfold/families/glm5_next/cuda/engine.py`, `tensorfold/families/glm5_next/cuda/forward.py`, `tensorfold/families/glm5_next/cuda/graphs.py`
- `0119-glm-full-text-calibration.patch`: `tensorfold/families/glm5_next/cuda/engine.py`
- `0120-glm-full-cp-short-select.patch`: `tensorfold/families/glm5_next/cuda/engine.py`, `tensorfold/families/glm5_next/cuda/forward.py`
- `0121-glm-full-graph-roce-check.patch`: `tensorfold/families/glm5_next/cuda/decode.py`
- `0122-glm-full-serial-stop.patch`: `tensorfold/cuda/server.py`, `tensorfold/families/glm5_next/cuda/decode.py`, `tensorfold/families/glm5_next/cuda/draft_dump.py`, `tensorfold/families/glm5_next/cuda/drafter_choice.py`, `tensorfold/families/glm5_next/cuda/engine.py`
- `0123-glm-full-dspark-dump.patch`: `tensorfold/families/glm5_next/cuda/draft_dump.py`, `tensorfold/families/glm5_next/cuda/dspark_sim.py`
- `0124-glm-full-mem-trace.patch`: `tensorfold/families/glm5_next/cuda/decode.py`, `tensorfold/families/glm5_next/cuda/engine.py`
- `0125-glm-full-dspark-host-markov.patch`: `tensorfold/families/glm5_next/cuda/dspark.py`, `tensorfold/families/glm5_next/cuda/dspark_sim.py`
- `0126-glm-full-calibration-windows.patch`: `tensorfold/families/glm5_next/cuda/engine.py`
- `0127-glm-full-moe-overlap.patch`: `tensorfold/families/glm5_next/cuda/dspark_sim.py`, `tensorfold/families/glm5_next/cuda/forward.py`, `tensorfold/families/glm5_next/cuda/hcsplit.py`
- `0128-glm-full-expert-prefetch.patch`: `tensorfold/cuda/exl3/experts.cu`, `tensorfold/cuda/exl3/experts.py`, `tensorfold/cuda/exl3/experts_grouped.cuh`
- `0129-glm-full-cp-prompt-msa.patch`: `tensorfold/families/glm5_next/cuda/forward.py`, `tensorfold/families/glm5_next/cuda/msa.cpp`, `tensorfold/families/glm5_next/cuda/msa.cu`, `tensorfold/families/glm5_next/cuda/msa.py`
- `0130-glm-full-multi-verify.patch`: `tensorfold/families/glm5_next/cuda/forward.py`, `tensorfold/families/glm5_next/cuda/verify.py`
- `0131-glm-full-cp-prompt-pipe.patch`: `tensorfold/families/glm5_next/cuda/dcp.py`, `tensorfold/families/glm5_next/cuda/forward.py`
- `0132-glm-full-prompt-disk-cache.patch`: `tensorfold/families/glm5_next/cuda/decode.py`, `tensorfold/families/glm5_next/cuda/engine.py`, `tensorfold/families/glm5_next/cuda/forward.py`, `tensorfold/families/glm5_next/cuda/pcache.py`
- `0133-glm-full-kv-fp4x.patch`: `tensorfold/cuda/geometry.py`, `tensorfold/families/glm5_next/cuda/dcp.py`, `tensorfold/families/glm5_next/cuda/dsa_full.py`, `tensorfold/families/glm5_next/cuda/engine.py`, `tensorfold/families/glm5_next/cuda/forward.py`, `tensorfold/families/glm5_next/cuda/kv8.py`, `tensorfold/families/glm5_next/cuda/latent.py`, `tensorfold/families/glm5_next/cuda/msa.cpp`, `tensorfold/families/glm5_next/cuda/msa.cu`, `tensorfold/families/glm5_next/cuda/msa.py`
- `0134-glm-full-multi-serve.patch`: `tensorfold/families/glm5_next/cuda/dflash2_multi.py`, `tensorfold/families/glm5_next/cuda/dspark.py`, `tensorfold/families/glm5_next/cuda/dspark_multi.py`, `tensorfold/families/glm5_next/cuda/engine.py`, `tensorfold/families/glm5_next/cuda/forward.py`, `tensorfold/families/glm5_next/cuda/multi.py`, `tensorfold/families/glm5_next/cuda/multi_prefill.py`
- `0135-glm-full-cp-prompt-raw-q.patch`: `tensorfold/cuda/geometry.py`, `tensorfold/families/glm5_next/cuda/dcp.py`, `tensorfold/families/glm5_next/cuda/engine.py`, `tensorfold/families/glm5_next/cuda/forward.py`, `tensorfold/families/glm5_next/cuda/weights.py`
- `0136-glm-full-chunk3k.patch`: `tensorfold/cuda/exl3/experts.cu`, `tensorfold/cuda/exl3/experts.py`, `tensorfold/cuda/exl3/mpe.py`, `tensorfold/cuda/geometry.py`, `tensorfold/families/glm5_next/cuda/forward.py`
- `0137-glm-full-kv-fp4x-fix.patch`: `tensorfold/families/glm5_next/cuda/dsa_full.py`, `tensorfold/families/glm5_next/cuda/kv8.py`
- `0138-glm-full-multi-kernels.patch`: `tensorfold/families/glm5_next/cuda/dsa_full.py`, `tensorfold/families/glm5_next/cuda/full_seg.py`, `tensorfold/families/glm5_next/cuda/kv8.py`, `tensorfold/families/glm5_next/cuda/latent.py`
- `0139-glm-full-multi-graphs.patch`: `tensorfold/families/glm5_next/cuda/dspark_multi.py`, `tensorfold/families/glm5_next/cuda/engine.py`, `tensorfold/families/glm5_next/cuda/full_seg.py`, `tensorfold/families/glm5_next/cuda/multi.py`
- `0140-glm-full-copy-hybrid.patch`: `tensorfold/families/glm5_next/cuda/copy_drafts.py`, `tensorfold/families/glm5_next/cuda/copy_sim.py`, `tensorfold/families/glm5_next/cuda/decode.py`, `tensorfold/families/glm5_next/cuda/draft_dump.py`, `tensorfold/families/glm5_next/cuda/dspark.py`, `tensorfold/families/glm5_next/cuda/dspark_sim.py`, `tensorfold/families/glm5_next/cuda/engine.py`
- `0141-glm-full-cp-kv-gather.patch`: `tensorfold/cuda/geometry.py`, `tensorfold/families/glm5_next/cuda/dcp.py`, `tensorfold/families/glm5_next/cuda/engine.py`, `tensorfold/families/glm5_next/cuda/forward.py`, `tensorfold/families/glm5_next/cuda/msa.cpp`, `tensorfold/families/glm5_next/cuda/msa.cu`, `tensorfold/families/glm5_next/cuda/msa.py`
