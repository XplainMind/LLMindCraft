FROM ghcr.io/huggingface/text-generation-inference:1.3

RUN python3 -m pip install -U --no-cache-dir tiktoken
RUN python3 -m pip install -U --no-cache-dir transformers_stream_generator