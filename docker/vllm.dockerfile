FROM nvcr.io/nvidia/pytorch:24.01-py3

RUN pip install -U --no-cache-dir pip
RUN python3 -m pip install -U --no-cache-dir transformers-stream-generator 
RUN python3 -m pip install -U --no-cache-dir tiktoken 

RUN TORCH_CUDA_ARCH_LIST="7.0;7.5;8.0;8.6;8.9;9.0" \
    && MAX_JOBS=208 \
    && pip install vllm==0.3.2

ENTRYPOINT ["/usr/bin/python", "-m", "vllm.entrypoints.openai.api_server"]
CMD ["--tensor-parallel-size", "8"]