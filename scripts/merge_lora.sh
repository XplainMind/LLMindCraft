PROJECT_PATH=...
export PYTHONPATH=$PROJECT_PATH

python src/merge_llama_with_lora.py \
    --model_name_or_path ... \
    --lora_path ... \
    --output_path ... \
    --llama
