
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
||[https://github.com/Dai-shen/LAiW](https://github.com/Dai-shen/LAiW)|Legal|[5]|



[1] Xie, Q., Han, W., Zhang, X., Lai, Y., Peng, M., Lopez-Lira, A. and Huang, J., 2023. PIXIU: A Large Language Model, Instruction Data and Evaluation Benchmark for Finance. arXiv preprint arXiv:2306.05443. **(Accepted by NeurIPS 2023 Dataset and Benchmark Track)**


[2] Yang, K., Zhang, T., Kuang, Z., Xie, Q. and Ananiadou, S., 2023. MentalLLaMA: Interpretable Mental Health Analysis on Social Media with Large Language Models. arXiv preprint arXiv:2309.13567.

[3] Yuan, C., Xie, Q., Huang, J. and Ananiadou, S., 2018. Back to the Future: Towards Explainable Temporal Reasoning with Large Language Models.

[4] Feng, D., Dai, Y., Huang, J., Zhang, Y., Xie, Q., Han, W., Lopez-Lira, A. and Wang, H., 2023. Empowering Many, Biasing a Few: Generalist Credit Scoring through Large Language Models. arXiv preprint arXiv:2310.00566.

[5] Dai, Y., Feng, D., Huang, J., Jia, H., Xie, Q., Zhang, Y., Han, W., Tian, W. and Wang, H., 2023. LAiW: A Chinese Legal Large Language Models Benchmark (A Technical Report). arXiv preprint arXiv:2310.05620.

## Docker environment
```bash
docker pull tothemoon/llm
```
This image packages all environments of LLMindCraft. 

## Fine-tuning in Docker environment
For **single node**:
```bash
docker run --gpus all \
    -d --rm \
    --name llm \
    [-v host_path:container_path] \
    [-w workdir] \
    --entrypoint "/bin/bash -c" \
    tothemoon/llm \
    --cmd "sleep infinity"
```
while for **multiple nodes**:
```bash
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

You can also enter the container by
```bash
docker exec -it llm /bin/bash
```

## Create New Dataset

Create a new data class in `preprocess.py`, like:

Your dataset should be created in the following format:

```python
class MedMCQA(InstructionDataset):
    dataset = "MedMCQA"
    task_type = "classification"
    choices = ["A", "B", "C", "D"]
    prompt = """Given a medical context and a multiple choice question related to it, select the correct answer from the four options.
Question: {text}
Options: {options}.
Please answer with A, B, C, or D only.
Answer:
"""

    def fetch_data(self, datum):
        return {
            "text": datum["question"], "options": ', '.join([op+': '+datum[k] for k, op in zip(['opa', 'opb', 'opc', 'opd'], self.choices)]),
            "answer": self.choices[datum["cop"]-1],
        }
```

In this format:

- `dataset`: The dataset name
- `task_type`: Your task type, should be `classification` or `abstractivesummarization` (TODO: More task types)
- `prompt`: The prompt of the task, which should be later used to be filled with the real data

For **Classification** tasks, additional keys should be defined:

- `choices`: Set of labels

> `fetch_data` is the interface for fetching the required features from raw data

And you should also append your class in the dictionary:

```python
DATASETS = {
    "MedMCQA": MedMCQA,
}

```

Finally, you can build and upload the dataset by:
```bash
bash preprocess.sh
```
Note that the parameters in the `preprocess.sh` should be changed accordingly. For evaluation datasets, `-for_eval` should be used, while for instruction tuning datasets, it should be omitted.
