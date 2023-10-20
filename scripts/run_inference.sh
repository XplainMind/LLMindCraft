export ABS_PATH=...
export PYTHONPATH="$ABS_PATH"
export CUDA_VISIBLE_DEVICES='0,1,2,3,4,5,6,7'

ckpt_path=...
infer_file=$ABS_PATH/data/test_data/test_infer.jsonl

# ft
python src/inference/inference.py \
    --ckpt_path $ckpt_path \
    --llama \
    --infer_file $infer_file \
    # --lora_path ... \
    # --use_lora
