#!/usr/bin/env bash

# Virtual environment setup
export VENV_DIR="$HOME/Virtual/Python/.python-${PyVersion}"
export REQUIREMENTS="/etc/nixos/dev-shells/R${PyVersion}.txt"

if [ ! -d "$VENV_DIR" ]; then
  echo "Creating virtual environment at $VENV_DIR..."
  python -m venv "$VENV_DIR"
  source "$VENV_DIR/bin/activate"
  uv pip install --upgrade pip
  uv pip install -r "$REQUIREMENTS"
else
  echo "Activating existing virtual environment at $VENV_DIR..."
  source "$VENV_DIR/bin/activate"
fi

# CUDA configuration
if [ "$enableCuda" = "1" ]; then
  echo "Setting up CUDA environment..."
  export CUDA_HOME="${CUDA_PATH}"
  export LD_LIBRARY_PATH="${LIBRARY_PATH}:$LD_LIBRARY_PATH"
fi

# Development environment
export PYTHONDONTWRITEBYTECODE=1
export PYTHONUNBUFFERED=1
export PYTHONASYNCIODEBUG=1

echo "Environment setup complete! 🚀"