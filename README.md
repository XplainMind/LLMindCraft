
# LLMindCraft 

[![License: CC BY-NC-ND 4.0](https://img.shields.io/badge/License-CC_BY--NC--ND_4.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc-nd/4.0/)


Shaping Language Models with Cognitive Insights

LLMindCraft by **XplainMind** Lab is licensed under [CC BY-NC-ND 4.0](https://creativecommons.org/licenses/by-nc-nd/4.0/).

## Downstream Applications

| Logo | Repository                 | Domain                            |  Paper |
| ----- | --------------------- | -------------------------------- |------ |
|[![](https://i.postimg.cc/xTpWgq3L/pixiu-logo.png)](https://github.com/chancefocus/PIXIU)|[https://github.com/chancefocus/PIXIU](https://github.com/chancefocus/PIXIU)|Finance|[1]|
|[![](https://i.postimg.cc/J7Ds1tw6/CoLLaMA.jpg)](https://github.com/Denilah/CoLLaMA)|[https://github.com/Denilah/CoLLaMA](https://github.com/Denilah/CoLLaMA)|Code||
|[![](https://i.postimg.cc/0Nd8VxbL/logo.png)](https://github.com/SteveKGYang/MentalLLaMA)|[https://github.com/SteveKGYang/MentalLLaMA](https://github.com/SteveKGYang/MentalLLaMA)|Mental Health | [2]|
|[![](https://camo.githubusercontent.com/a1d8cf8dd52e8e85481b729c0590154436afe23364f935afe4cf905e82d79be0/68747470733a2f2f692e706f7374696d672e63632f634a4e374c4b59302f6c6f676f2e706e67)](https://github.com/chenhan97/TimeLlama)|[https://github.com/chenhan97/TimeLlama](https://github.com/chenhan97/TimeLlama)|Temporal Reasoning |[3]|
||[https://github.com/colfeng/CALM](https://github.com/colfeng/CALM)|Credit Scoring|[4]|
||[https://github.com/Dai-shen/LAiW](https://github.com/Dai-shen/LAiW)|Legal||



[1] Xie, Q., Han, W., Zhang, X., Lai, Y., Peng, M., Lopez-Lira, A. and Huang, J., 2023. PIXIU: A Large Language Model, Instruction Data and Evaluation Benchmark for Finance. arXiv preprint arXiv:2306.05443. **(Accepted by NeurIPS 2023 Dataset and Benchmark Track)**


[2] Yang, K., Zhang, T., Kuang, Z., Xie, Q. and Ananiadou, S., 2023. MentalLLaMA: Interpretable Mental Health Analysis on Social Media with Large Language Models. arXiv preprint arXiv:2309.13567.

[3] Yuan, C., Xie, Q., Huang, J. and Ananiadou, S., 2018. Back to the Future: Towards Explainable Temporal Reasoning with Large Language Models.

[4] Feng, D., Dai, Y., Huang, J., Zhang, Y., Xie, Q., Han, W., Lopez-Lira, A. and Wang, H., 2023. Empowering Many, Biasing a Few: Generalist Credit Scoring through Large Language Models. arXiv preprint arXiv:2310.00566.

## Docker environment
```bash
docker pull tothemoon/llm
```
This image packages all environments of LLMindCraft. 

## Fine-tuning in Docker environment

```bash
docker run --gpus all 
    -d --rm \
    --name llm \
    [-v host_path:container_path] \
    [-w workdir] \
    --entrypoint "/bin/bash -c" \
    tothemoon/llm \
    --cmd "sleep infinity"
```

You can also enter the container by
```bash
docker exec -it llm /bin/bash
```
