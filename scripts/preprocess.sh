#!/bin/bash

# Define the arguments
DATASET="Your Dataset"
TRAIN_FILENAME="Train Filename"
VALID_FILENAME="Valid Filename"
TEST_FILENAME="Test Filename"

# Call the Python script with the defined arguments
python src/preprocess.py \
  --dataset $DATASET \
  --train_filename $TRAIN_FILENAME \
  --valid_filename $VALID_FILENAME \
  --test_filename $TEST_FILENAME \
  --for_eval
