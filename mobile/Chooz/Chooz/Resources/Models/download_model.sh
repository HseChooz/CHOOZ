#!/bin/bash
# Downloads the Qwen2.5-0.5B CoreML model from HuggingFace.
# Run this script once before building the project.
#
# Prerequisites: git-lfs (brew install git-lfs)
#
# The model will be placed in this directory and included in the app bundle
# via Tuist's resources: ["Chooz/Resources/**"] rule.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MODEL_DIR="$SCRIPT_DIR/Qwen2.5-0.5B"

if [ -d "$MODEL_DIR" ]; then
    echo "Model already downloaded at $MODEL_DIR"
    exit 0
fi

echo "Downloading Qwen2.5-0.5B CoreML model..."
git lfs install
git clone https://huggingface.co/mlboydaisuke/qwen2.5-0.5b-coreml "$MODEL_DIR"

echo "Done. Model saved to $MODEL_DIR"
