curr_date=20240226
docker tag llm harbor.intra.ke.com/asr/belle:latest && docker push harbor.intra.ke.com/asr/belle:latest
docker tag llm harbor.intra.ke.com/asr/belle:$curr_date && docker push harbor.intra.ke.com/asr/belle:$curr_date
docker tag vllm harbor.intra.ke.com/asr/vllm:latest && docker push harbor.intra.ke.com/asr/vllm:latest
docker tag vllm harbor.intra.ke.com/asr/vllm:$curr_date && docker push harbor.intra.ke.com/asr/vllm:$curr_date
docker tag vllm harbor.intra.ke.com/asr/vllm:0.3.2_cu123 && docker push harbor.intra.ke.com/asr/vllm:0.3.2_cu123

# docker tag harbor.intra.ke.com/asr/belle:latest tothemoon/belle:latest &&
#     docker push tothemoon/belle:latest &&
#     docker tag tothemoon/belle:latest tothemoon/llm:latest &&
#     docker push tothemoon/llm:latest &&
#     docker tag tothemoon/llm:latest tothemoon/llm:$curr_date &&
#     docker push tothemoon/llm:$curr_date &&
#     docker tag tothemoon/llm:latest tothemoon/belle:$curr_date &&
#     docker push tothemoon/belle:$curr_date
