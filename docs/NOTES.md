# Validation notes and limitations

These notes describe how the README's numbers were measured and what they do not show. Published measurements come
from the TensorFold v0.6.5 build or the earlier builds named below. They used four RTX PRO 6000 Blackwell Max-Q GPUs
in one PCIe host at a 250 W cap per GPU, except for correctness checks labeled as other hardware. The v0.6.6 A/B
validation used a separate Server Edition host. Every repetition and failed attempt is retained with the
qualification evidence; nothing below is a fastest-run selection.

## TensorFold v0.6.6

The recipe now runs TensorFold v0.6.6 with the same 151 engine patches. The [rebase notes](PORT-v0.6.6.md) record
the regenerated patch hashes and the exact tree comparison. Only hunk positions changed in ten patches. Mia's AI
Lab's patches remain hers.

On 2026-10-08, native A/B validation compared A, the current v0.6.5 build, with B, the v0.6.6 rebase, using the same
checkpoint and settings. It ran on four RTX PRO 6000 Blackwell Server Edition GPUs at 600 W per card, a separate
host from the published Max-Q measurements. Both arms used the production 1M profile: `CP=1`, `PARALLEL=5`,
`CONTEXT=1048576`, FP8 dense and KV, DSpark and the 1,245,184-token shared pool.

- Gate and gatelong passed with identical results at concurrency levels 1, 2, 4 and 5.
- First tokens and complete returned sequences matched on 40/40 requests, covering all 1,278 returned token IDs.
- Tool bursts matched A: 90/90 with default tool choice and 90/90 with required tool choice.
- The `--name-priority ID=background` smoke passed. An explicit normal request overtook an earlier implicit
  background request in the five-slot queue test. Without the option, both arms retained FIFO order.
- No throughput regression was observed. One-stream decode and cold prefill medians were within about 1%.
  Four-stream decode has a process warm-state limitation: the B1 block reused B0's process, while the other blocks
  started fresh processes. Its apparent gain is not a measured rebase speedup.

The configured 1M profile started and completed all tests on both arms. The largest actual long input was 99,889
tokens, so this was not a million-token prompt benchmark. These native A/B results check the rebase. They do not
replace the published container measurements on the Max-Q host, which remain attributed to the v0.6.5 build.

## The measured build

The remaining sections describe the v0.6.5 qualification and its named historical comparisons. References to the
final image below mean the measured v0.6.5 image.

- Engine source: TensorFold v0.6.5 plus the original 151 patches from release 1.0.0. Strict replay produced Git tree
  `ee3aad92acb885e6a48c28ad04f7c9f91ae6fb93`. The current `tools/check_apply.py` checks the v0.6.6 tree recorded in
  the [rebase notes](PORT-v0.6.6.md).
- Profile: `profiles/production.env`, SHA256 `29d5ed9b57dfa2ef78368e1672d316427e4e84984dda83f75dab1586ffb9a81c`.
- Checkpoint: the measured weights are revision `cf1fee89` of Mia's AI Lab's checkpoint with the `config.json` of
  revision `2d747d0e`. Between those revisions all 137 weight shards, the tokenizer, chat template, generation and
  quantization configuration are identical, and `config.json` of `2d747d0e` is the qualified configuration
  (SHA256 `e7d294bd...`). The recipe therefore pins `2d747d0e` and checks that hash after download.
- Launcher: `serve.sh` and `scripts/start-integrated.sh` are the measured launcher, byte for byte. With Docker
  replaced by a recorder, `start.sh` produces the same four container commands and the same values for every forwarded
  engine variable as the measured deployment.
- Fresh clone: on the measured host, a fresh clone with an empty data directory and no Hugging Face token built the
  image, downloaded the pinned checkpoint and drafter (about 275 GB), started with empty kernel caches in 8 minutes and
  passed the smoke request. On 40 fixed prompts of 1,645 to 30,995 tokens (`tools/bench/first_tokens.py`, greedy,
  32 tokens), its replies matched the measured deployment token for token, 40 of 40. The build resolves a few unpinned
  helper packages when it runs; on that run `hf-xet` and `typer` were one release newer than in the measured image,
  and the installed engine sources were identical.

## Populated sessions

Each session receives its own synthetic prompt of the named size with a needle near 95% of its content. The cell fills
every session once, checks each needle, then replays the same prompts for 400-token greedy replies (temperature 0,
seed 1234, thinking off), first all sessions together and then each alone. Each concurrent reply must equal its solo
reply, and both the server's decoding count and the output intervals must show the sessions overlapping. The
aggregate rate divides all output tokens by the batch's wall time, including startup and any cache-resume interval;
it is not an engine-only decode rate. A nominal window label is not the prompt length: the README gives the actual
prompt tokens.

The same requests ran on an earlier build of this recipe: 4 × 256K at 67.79 tok/s and 2 × 512K at 45.03 tok/s, against
86.44 and 65.10 tok/s on the final image. Profiles and patches differ between the two builds, so the differences are
not attributable to a single patch.

## Short prompts

The README's concurrency table is from sparkDash v1.8.9 on the final v13 image with the production 1M profile,
measured on 2026-10-08. Each cell uses the median-aggregate run of three repeats. This is the TensorFold v0.6.5
build. Decode TTFT is warm because sparkDash repeats the same short prompt; cold prefill uses unique prompts.

Earlier v10 qualification used one pass per cell with a 32K allocation and a 196,608-token pool. It contained the
selected multi-session configuration: a 128-entry graph cache with row padding, batched exchanges and native
paging, with batch draft blocks off. The final v13 image added prompt-cache tiers, vLLM-named metrics and four
kernel patches. Those earlier v10 results are separate from the README's current table.

### Single-session allocation

A one-session allocation (`PARALLEL=1`, 32K) is a different profile from one stream on the five-session allocation.
Three 400-token native trials per workload on the qualification build of the four kernel patches gave these medians:

| Mode | Prose | Code | Structured |
| --- | ---: | ---: | ---: |
| `CP=1` | 92.57 tok/s | 144.73 tok/s | 161.99 tok/s |
| `CP=0` | 106.52 tok/s | 156.69 tok/s | 183.08 tok/s |

`CP=0` is faster for short single sessions, but it replicates the KV cache across the GPUs and admits far less
context; its long-context admission has not been measured on the final image.

## Prefill and needles

The cold grid sends unique prompts with no cached tokens and records the server's cached-token count, which was zero
for every row. It ran after the long needles on the same server, and the 256K row overlapped a 4.307 s parking write.
The two original long needles hide a passphrase near 60% depth in prompts of 786,602 and 996,320 tokens; they passed
with replies identical to the unmodified v0.6.5 port of the original recipe. Those speed comparisons are separate
windows on the same hardware, not interleaved trials.

## Prompt resume and warm turns

Resume rows replay the unchanged request after evicting its prompt to the named tier, then check the reported tier,
the cached-token count and the complete output. The v11 table also restores a prompt while another session decodes
and records that session's longest gap between streamed chunks. Warm turns append a user turn to the conversation and
record the growing prompt and the reused tokens. At 747,292 tokens, appends after the first took 13.83 to 14.43 s,
most of it server-side prefill of the short new turn; the cause has not been isolated.

## Teacher KL

The reference is a forward pass of the official block-scaled FP8 GLM-5.3 weights, dequantized for FP16 arithmetic
with FP32 residuals, over the model's 78 text layers; dynamic FP8 activation quantization is not emulated, and the
reference is not shown to equal the BF16 or W8A8 runtime. The frozen panel has 32 windows of 2,048 scored positions
and 4 long windows with 6,144-token prefixes, 73,728 positions in total. Engine captures are full-vocabulary FP32
logits; the unchanged scorer renormalizes them in FP64 and computes KL(teacher || engine), with 20,000 paired window
bootstraps stratified by window type. The final image's FP8 and FP4 KV captures ran on a separate four-GPU RTX PRO
6000 Server Edition machine with the pinned runtime: they establish correctness, and all 36 logit files per format
were byte-identical to the same-format references captured earlier on the measured hardware.

## Hardware and limits

Sampled peaks across the final windows were 94,636 MiB per GPU and 91, 88, 90 and 88 C. Power caps were 250 W on every
card, software power capping was active, and the thermal-slowdown and power-brake counters did not advance.

Known limits:

- Exact-copy retrieval is not established near 1M tokens; see the README's retrieval section.
- Parking writes are synchronous: a restore near 1M tokens raised another session's longest stream pause from about
  0.089 s to 3.387 s on the v11 build.
- The RAM tier does not survive a restart, sessions that were never parked are not stored durably, and image or
  video states are not parked.
- FP4 and FP4X KV have the measured teacher-KL cost in the README; FP8 KV is the quality reference.
- The optional DFlash2 drafter path and standard mode (`CP=0`) at long context have not been qualified on this
  build. Structured outputs with `response_format` have not been probed on this build.
