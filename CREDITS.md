# Credits

This release is by [Aevonix Research](https://aevonix.com). It builds on the following work:

- **[TensorFold](https://github.com/ashhart/TensorFold)** by Ash Hart
  ([X @ashxhart](https://x.com/ashxhart)) and its contributors: the inference engine, EXL3 kernels,
  speculative verification and API. TensorFold is Apache-2.0; its earlier code retains MIT notices.
- **[Mia's AI Lab](https://huggingface.co/Mia-AiLab)**
  ([X @MiaAI_lab](https://x.com/MiaAI_lab)): the
  [EXL3 checkpoint](https://huggingface.co/Mia-AiLab/GLM-5.3-EXL3-2.75bpw-TensorFold) and the
  [full GLM-5.3 recipe and patches](https://github.com/MiaAI-Lab/GLM-5.3-EXL3-3x-DGX-Sparks-TensorFold) that this
  build ports. This release carries 106 of her 110 patches, originally ported from TensorFold v0.6.0 to v0.6.5,
  then rebased to v0.6.6. TensorFold v0.6.5 already contains the other four. Her patches remain hers, including the
  nine regenerated for this rebase.
- **[Z.ai](https://huggingface.co/zai-org/GLM-5.3)**: GLM-5.3, its architecture and base weights.
- **[Red Hat AI](https://huggingface.co/RedHatAI/GLM-5.3-speculator.dspark)**: the DSpark speculator, the default
  drafter, under the GLM-5.3 License its model card names. It is downloaded from its source and not redistributed.
- **[drowzeys](https://github.com/drowzeys/TensorFold)**: the prompt-expert kernels and the context-parallel scheme
  that Mia's patches 0106, 0112 and 0113 adapt from their TensorFold fork (Apache-2.0).
- **[vLLM](https://github.com/vllm-project/vllm) and [speculators](https://github.com/vllm-project/speculators)**:
  the DSpark drafter forward that Mia's patch 0114 adapts (Apache-2.0).
- **[glm53-tensorfold-spark](https://github.com/jayleaton/glm53-tensorfold-spark)** by Jay Leaton: tool-call
  handling, L2 prefetch and 16-byte EXL3 load ideas adapted in Mia's patches (Apache-2.0).
- **[b12x](https://github.com/local-inference-lab/b12x)**: the RoCE transport in Mia's patch 0006 (Apache-2.0).
- **[ExLlamaV3](https://github.com/turboderp-org/exllamav3)** by turboderp: the EXL3 format (MIT).
- **Contributors to the GLM-5.3-Flash recipe**: [abhicnv007](https://github.com/abhicnv007),
  [Alexbob0](https://github.com/Alexbob0) and [kky42](https://github.com/kky42), whose contributions are in Mia's
  patches 0054, 0057 and 0060.
- **NVIDIA, PyTorch, Triton, Hugging Face, PyAV and xgrammar**: the GPU runtime, tensor and kernel stack,
  model hosting, media decoding and structured output support, under their respective licenses.
- **Geist and Geist Mono** by the Geist Project Authors: fonts used in the Aevonix Research artwork,
  under the SIL Open Font License 1.1.
- **DejaVu Sans Mono**: terminal artwork rendering, including the block and box-drawing glyphs.

Aevonix Research adds the original TensorFold v0.6.5 port and the v0.6.6 rebase of the full GLM-5.3 patches,
45 engine patches, 4 build patches, the single-host recipe and its qualification. The [patch table](docs/PATCHES.md)
describes each contribution. The [original port notes](docs/PORT-v0.6.5.md) record each of Mia's AI Lab's patches;
the [v0.6.6 rebase notes](docs/PORT-v0.6.6.md) record the regenerated patches. [NOTICE](NOTICE) preserves attribution and
modification notices, including the original recipe's notice; [LICENSE](LICENSE) covers this repository's code and
documentation.
