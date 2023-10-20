import json
import random
import argparse
import pandas as pd
from tqdm import tqdm
from datasets import Dataset, DatasetInfo, DatasetDict, Features, Value, load_dataset


def read_jsonl_data(filename):
    with open(filename) as f:
        data = f.readlines()
    data = [json.loads(val) for val in data]
    return data


def read_table_data(filename):
    data = pd.read_table(filename).to_dict('records')
    return data


def read_json_data(filename):
    data = json.load(open(filename)).values()
    return data


READ_METHODS = {
    "json": read_json_data,
    "jsonl": read_jsonl_data,
    "tsv": read_table_data,
}


class InstructionDataset:
    BASE_REPO = "hippocrates"

    def build_finetuning_instruction(self, data, prompt, index):
        return {"id": f"{self.dataset}{index}", "conversations": [
            {"from": "human", "value": prompt},
            {"from": "agent", "value": data["answer"]},
        ], "text": prompt,}

    def build_classification_instruction(self, data, prompt, index):
        return {"id": f"{self.dataset}{index}", "query": prompt,
                    "answer": data["answer"], "choices": self.choices,
                    "gold": self.choices.index(data["answer"])}

    def build_absumm_instruction(self, data, prompt, index):
        return {"id": f"{self.dataset}{index}", "query": prompt,
                    "answer": data["answer"]}

    def construct_instructions(self, data, eval_format=False, limit=None):
        instructions = []
        construct_dict = {
            "classification": self.build_classification_instruction,
            "abstractivesummarization": self.build_absumm_instruction}
        construct_method = construct_dict[self.task_type] if eval_format else self.build_finetuning_instruction

        for index, datum in enumerate(tqdm(data)):
            fetched_data = self.fetch_data(datum)
            filled_prompt = self.prompt.format(**fetched_data) 
            instruction = construct_method(
                fetched_data, filled_prompt, len(instructions))
            instructions.append(instruction)

        if not eval_format:
            random.shuffle(instructions)
            instructions = instructions if limit is None else instructions[:limit]

        with open("instructions.jsonl", "w") as f:
            for val in tqdm(instructions):
                f.write(json.dumps(val)+"\n")

        instructions = load_dataset("json", data_files="instructions.jsonl")

        return instructions

    def build_and_push(self, train_filename=None, valid_filename=None, test_filename=None, for_eval=False, limit=None):
        dataset_dict = {}
        for filename, split in zip([train_filename, valid_filename, test_filename], ["train", "valid", "test"]):
            posix = filename.split(".")[-1]
            read_method = READ_METHODS[posix]
            dataset_dict[split] = self.construct_instructions(read_method(filename), for_eval, limit)
        print (dataset_dict, for_eval)
        dataset_dict = DatasetDict(dataset_dict)
        dataset_dict.push_to_hub(f"{self.BASE_REPO}/{self.dataset}_{'train' if not for_eval else 'test'}")


DATASETS = {
}


def main():
    parser = argparse.ArgumentParser(description='Process dataset for hippocrates training and evaluation.')

    parser.add_argument('--dataset', type=str, required=True, help='The dataset name')
    parser.add_argument('--train_filename', type=str, required=True, help='The training dataset filename')
    parser.add_argument('--valid_filename', type=str, required=True, help='The validation dataset filename')
    parser.add_argument('--test_filename', type=str, required=True, help='The test dataset filename')
    parser.add_argument('--for_eval', action='store_true', help='Set to true for evaluation, false otherwise')
    parser.add_argument('--limit', type=int, help='The generation number of the dataset')

    args = parser.parse_args()

    dataset = args.dataset
    train_filename = args.train_filename
    valid_filename = args.valid_filename
    test_filename = args.test_filename
    for_eval = args.for_eval
    limit = args.limit

    # Your processing code here
    data_class = DATASETS[dataset]()
    data_class.build_and_push(train_filename=train_filename, valid_filename=valid_filename, test_filename=test_filename, for_eval=for_eval, limit=limit)


if __name__ == '__main__':
    main()
