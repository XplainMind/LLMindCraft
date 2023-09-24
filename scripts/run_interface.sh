export ABS_PATH=...
export PYTHONPATH="$ABS_PATH/src"
export CUDA_VISIBLE_DEVICES='0,1,2,3,4,5,6,7'

ckpt_path=...

# ft
python src/inference/interface.py \
    --ckpt_path $ckpt_path \
    --llama \
    --local_rank $1 \
    # --use_lora \
    # --lora_path
