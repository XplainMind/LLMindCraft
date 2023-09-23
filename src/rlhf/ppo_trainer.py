from typing import Callable, List, Union, Optional
from pathlib import Path
import torch
from trl import PPOTrainer
from src.generation_utils import GenerationMixin
from transformers.deepspeed import is_deepspeed_zero3_enabled
from transformers.modeling_utils import PreTrainedModel
from src.utils import bind_methods_from_class_to_instance, get_ds_state_dict


class PPOTrainerForZero3(PPOTrainer):
    def _generate_batched(
        self,
        query_tensors: List[torch.Tensor],
        length_sampler: Callable = None,
        batch_size: int = 4,
        return_prompt: bool = True,
        pad_to_multiple_of: int = None,
        remove_padding: bool = True,
        **generation_kwargs,
    ):
        outputs = []

        padding_side_default = self.tokenizer.padding_side
        if not self.is_encoder_decoder:
            self.tokenizer.padding_side = "left"

        # in case we have fewer examples than bs
        batch_size = min(len(query_tensors), batch_size)

        for i in range(0, len(query_tensors), batch_size):
            if length_sampler is not None:
                generation_kwargs["max_new_tokens"] = length_sampler()

            # prevent overflow if query tensors are not even multiple of bs
            end_index = min(len(query_tensors), i + batch_size)

            batch = query_tensors[i:end_index]
            batch_mask = [torch.ones_like(element) for element in batch]
            inputs = {"input_ids": batch, "attention_mask": batch_mask}

            padded_inputs = self.tokenizer.pad(
                inputs,
                padding=True,
                max_length=None,
                pad_to_multiple_of=pad_to_multiple_of,
                return_tensors="pt",
            ).to(self.current_device)
            
            unwrap_model = self.accelerator.unwrap_model(self.model).pretrained_model
            bind_methods_from_class_to_instance(
                unwrap_model,
                GenerationMixin,
                include=[
                    "contrastive_search",
                    "greedy_search",
                    "sample",
                    "beam_search",
                    "beam_sample",
                    "group_beam_search",
                    "constrained_beam_search",
                    "assisted_decoding",
                    "generate"
                ]
            )
            generations = unwrap_model.generate(
                deepspeed_model=self.model,
                **padded_inputs, 
                **generation_kwargs, 
                synced_gpus=True
            )
            # generations = self.accelerator.unwrap_model(self.model).generate(
            #     **padded_inputs, **generation_kwargs
            # )

            for generation, mask in zip(generations, padded_inputs["attention_mask"]):
                if not self.is_encoder_decoder:
                    output = generation[(1 - mask).sum() :]  # remove padding
                else:
                    output = generation

                if not return_prompt and not self.is_encoder_decoder:
                    output = output[(mask).sum() :]  # remove prompt

                if remove_padding and self.tokenizer.eos_token_id in output:
                    pad_mask = output == self.tokenizer.eos_token_id
                    pad_start = torch.nonzero(pad_mask, as_tuple=False)[0, 0].item()
                    output = output[: pad_start + 1]  # keep the eos token at the end

                outputs.append(output)

        self.tokenizer.padding_side = padding_side_default
        return outputs

    def save_pretrained(
        self,
        save_directory: Union[str, Path],
        *,
        config: Optional[dict] = None,
        repo_id: Optional[str] = None,
        push_to_hub: bool = False,
        **kwargs
    ):
        is_deepspeed_used = self.accelerator.distributed_type == "DEEPSPEED" and hasattr(
            self.accelerator.state, "deepspeed_plugin"
        )
        if not is_deepspeed_used:
            if self.accelerator.is_main_process:
                super().save_pretrained(save_directory, config=config, repo_id=repo_id, push_to_hub=push_to_hub, **kwargs)
        else:
            if self.accelerator.state.deepspeed_plugin.deepspeed_config["zero_optimization"]["stage"] == 3:
                state_dict = get_ds_state_dict(self.model)
            else:
                # Only run on rank 0 except stage 3
                if self.accelerator.is_main_process:
                    state_dict = get_ds_state_dict(self.model)
            
            if self.accelerator.is_main_process:
                unwrap_model: PreTrainedModel = self.accelerator.unwrap_model(self.model).pretrained_model
                unwrap_model.save_pretrained(save_directory, state_dict=state_dict)