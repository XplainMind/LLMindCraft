
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
|[![]()]|[https://github.com/chenhan97/TimeLlama](https://github.com/chenhan97/TimeLlama)|Temporal Reasoning ||
||[https://github.com/colfeng/CALM](https://github.com/colfeng/CALM)|Credit Scoring||

[1] Xie, Q., Han, W., Zhang, X., Lai, Y., Peng, M., Lopez-Lira, A. and Huang, J., 2023. PIXIU: A Large Language Model, Instruction Data and Evaluation Benchmark for Finance. arXiv preprint arXiv:2306.05443. **(Accepted by NeurIPS 2023 Dataset and Benchmark Track)**


[2] Yang, K., Zhang, T., Kuang, Z., Xie, Q. and Ananiadou, S., 2023. MentalLLaMA: Interpretable Mental Health Analysis on Social Media with Large Language Models. arXiv preprint arXiv:2309.13567.


## Docker environment
```bash
docker pull tothemoon/llm
```
This image packages all environments of LLMindCraft. You can start the image by following command:
```
docker run --gpus all --ipc=host --ulimit memlock=-1 --ulimit stack=67108864 \
    --privileged \
    --network host \
    [--env env_variable=value] \
    -d --rm \
    --name llm \
    [-v host_path:container_path] \
    [-v ssh_pub_key:/root/.ssh/authorized_keys] \
    [-w workdir] \
    tothemoon/llm \
    --sshd_port [any_port] --cmd "sleep infinity"
```
The entry point of the container starts a sshd process, then it `sleep infinity`, so you can work in container by ssh connection.
```bash
ssh -p [any_port] -i [private_key] root@host_ip
```
You can also enter the container by
```bash
docker exec -it llm /bin/bash
```
