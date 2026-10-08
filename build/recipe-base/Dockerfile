FROM nvcr.io/nvidia/pytorch:26.07-py3
COPY TensorFold /opt/TensorFold
RUN pip install --no-cache-dir /opt/TensorFold 'av==18.1.0' 'xgrammar>=0.2.8,<0.3' 'jsonschema>=4.18'
ENV TORCH_CUDA_ARCH_LIST=12.0 TORCH_EXTENSIONS_DIR=/cache/torch_extensions TRITON_CACHE_DIR=/cache/triton MAX_JOBS=4
WORKDIR /workspace
