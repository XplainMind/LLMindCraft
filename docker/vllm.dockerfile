FROM nvcr.io/nvidia/pytorch:23.11-py3
# FROM nvcr.io/nvidia/pytorch:22.12-py3

RUN pip install -U --no-cache-dir pip
RUN python3 -m pip install -U --no-cache-dir transformers-stream-generator 
RUN python3 -m pip install -U --no-cache-dir tiktoken 

# WORKDIR /workspace
# RUN cd /workspace \
#     && git clone https://github.com/vllm-project/vllm.git \
#     && cd vllm \
RUN TORCH_CUDA_ARCH_LIST="7.0;7.5;8.0;8.6;8.9;9.0" \
    && MAX_JOBS=4 \
    && pip install vllm==0.3.1

ENTRYPOINT ["/usr/bin/python", "-m", "vllm.entrypoints.openai.api_server"]
CMD ["--tensor-parallel-size", "8"]