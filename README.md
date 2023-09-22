[![License: CC BY-NC-ND 4.0](https://img.shields.io/badge/License-CC_BY--NC--ND_4.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc-nd/4.0/)
# LLMindCraft 
Shaping Language Models with Cognitive Insights

LLMindCraft by Nature Language Processing Lab of Wuhan University is licensed under CC BY-NC-ND 4.0. 

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