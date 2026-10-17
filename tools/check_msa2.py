#!/usr/bin/env python3
"""Check TF_GLM_MSA2 (patch aevonix-mia-237) against msa_kernel with patches 235 and 236, byte for byte, on one GPU.

The same seeded inputs go through tensorfold's msa module in two processes, TF_GLM_MSA2 unset and TF_GLM_MSA2=1,
both with TF_GLM_MSA_HALF_HEADS=1 and TF_GLM_MSA_SKIP_EMPTY_QK=1. Cases: 16, 12 and 8 local heads; prompt and
prompt_lse; 517 rows with token counts from 0 to 2,048 (0, 1, 31, 32, 33 and 2,048 included); zero, subnormal and
extreme e4m3 codes in the FP8 latent cache. A timing line compares the two kernels on a full 3,072-row chunk.

Usage, inside the image with a GPU: python3 tools/check_msa2.py
Exit 0 when every output is bit-identical, 1 otherwise.
"""
import os
import subprocess
import sys
import tempfile

LW, RD, W, CTX = 512, 64, 2048, 20000


def run(out_path):
    import torch
    from tensorfold.families.glm5_next.cuda import msa

    dev = "cuda"
    g = torch.Generator(device=dev).manual_seed(11)
    codes = (torch.randint(0, 0x7F, (CTX, LW), device=dev, dtype=torch.int32, generator=g)
             | (torch.randint(0, 2, (CTX, LW), device=dev, dtype=torch.int32, generator=g) * 0x80)).to(torch.uint8)
    codes[:, :8] = torch.tensor([0x00, 0x01, 0x07, 0x80, 0x81, 0x08, 0x7E, 0xFE], dtype=torch.uint8, device=dev)
    cache = torch.zeros((CTX, LW + 16), device=dev, dtype=torch.uint8)
    cache[:, :LW] = codes
    exps = torch.randint(-8, 2, (CTX,), device=dev, generator=g).float()
    cache[:, LW:LW + 4] = torch.pow(2.0, exps).view(torch.uint8).view(CTX, 4)
    rope = (torch.randn((CTX, RD), device=dev, generator=g) * 0.5).to(torch.bfloat16)
    scale = 576 ** -0.5
    results = {}
    for H in (16, 12, 8):
        R = 517
        qa = (torch.randn((R, H, LW), device=dev, generator=g) * 0.05).to(torch.bfloat16)
        qp = (torch.randn((R, H, RD), device=dev, generator=g) * 0.05).to(torch.bfloat16)
        counts = torch.randint(0, W + 1, (R,), device=dev, dtype=torch.int32, generator=g)
        counts[:6] = torch.tensor([0, 1, 31, 32, 33, W], dtype=torch.int32, device=dev)
        tokens = torch.full((R, W), -1, device=dev, dtype=torch.int32)
        for r in range(R):
            n = int(counts[r])
            if n:
                tokens[r, :n] = torch.randperm(CTX, device=dev, generator=g)[:n].sort().values.int()
        out = torch.full((R, H, LW), 7.0, device=dev, dtype=torch.bfloat16)
        msa.prompt(qa, cache, tokens, counts, out, scale, qp, rope)
        results[f"H{H} prompt out"] = out.cpu()
        out = torch.full((R, H, LW), 7.0, device=dev, dtype=torch.bfloat16)
        lse = torch.full((R, H), 5.0, device=dev, dtype=torch.float32)
        msa.prompt_lse(qa, cache, tokens, counts, out, lse, scale, qp, rope)
        results[f"H{H} prompt_lse out"] = out.cpu()
        results[f"H{H} prompt_lse lse"] = lse.cpu()
    R, H = 3072, 16                                     # a full prompt chunk at TP4 for the timing line
    qa = (torch.randn((R, H, LW), device=dev, generator=g) * 0.05).to(torch.bfloat16)
    qp = (torch.randn((R, H, RD), device=dev, generator=g) * 0.05).to(torch.bfloat16)
    tokens = torch.stack([torch.randperm(CTX, device=dev, generator=g)[:W].sort().values for _ in range(R)]).int()
    counts = torch.full((R,), W, device=dev, dtype=torch.int32)
    out = torch.empty((R, H, LW), device=dev, dtype=torch.bfloat16)
    for _ in range(3):
        msa.prompt(qa, cache, tokens, counts, out, scale, qp, rope)
    torch.cuda.synchronize()
    a, b = torch.cuda.Event(enable_timing=True), torch.cuda.Event(enable_timing=True)
    a.record()
    for _ in range(10):
        msa.prompt(qa, cache, tokens, counts, out, scale, qp, rope)
    b.record()
    torch.cuda.synchronize()
    results["ms"] = a.elapsed_time(b) / 10
    torch.save(results, out_path)


def main():
    if len(sys.argv) == 3 and sys.argv[1] == "--run":
        run(sys.argv[2])
        return 0
    import torch

    got = {}
    with tempfile.TemporaryDirectory() as tmp:
        for label, value in (("msa_kernel", None), ("msa2_kernel", "1")):
            env = dict(os.environ, TF_GLM_MSA_HALF_HEADS="1", TF_GLM_MSA_SKIP_EMPTY_QK="1")
            env.pop("TF_GLM_MSA2", None)
            if value is not None:
                env["TF_GLM_MSA2"] = value
            path = os.path.join(tmp, f"{label}.pt")
            subprocess.run([sys.executable, os.path.abspath(__file__), "--run", path], env=env, check=True)
            got[label] = torch.load(path)
    ref, new = got["msa_kernel"], got["msa2_kernel"]
    ok = True
    for key in ref:
        if key == "ms":
            continue
        a, b = ref[key], new[key]
        same = torch.equal(a.view(torch.int16) if a.dtype == torch.bfloat16 else a.view(torch.int32),
                           b.view(torch.int16) if b.dtype == torch.bfloat16 else b.view(torch.int32))
        ok &= same
        print(f"{'PASS' if same else 'FAIL'}: {key}")
    print(f"3,072-row chunk, 16 heads, 2,048 tokens a row: msa_kernel {ref['ms']:.3f} ms, "
          f"msa2_kernel {new['ms']:.3f} ms ({ref['ms'] / new['ms']:.2f}x)")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
