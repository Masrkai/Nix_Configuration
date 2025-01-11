# /etc/nixos/dev-shells/python-shell.nix
let
  # Import system configuration first
  systemConfig = import /etc/nixos/configuration.nix {
    system = builtins.currentSystem;
  };

  # Initialize nixpkgs with system config and CUDA settings
  pkgs = import <nixpkgs> {
    config = systemConfig.config;
    #  // {
    #   allowUnfree = true;
    #   cudaSupport = true;
    #   cudaCapabilities = [ "8.9" ];
    #   cudaForwardCompat = false;
    # };
  };
in
{ pkgs ? pkgs }:

let
  cuda-common-pkgs = with pkgs; [
        magma-cuda
        cudaPackages.nccl
        cudaPackages.cudnn
        cudaPackages.libnpp
        # cudaPackages.tensorrt  # Added for AI/ML acceleration
        cudaPackages.cuda_cccl
        cudaPackages.cuda_nvcc
        cudaPackages.cuda_cudart
  ];

  python-ml-pkgs = with pkgs.python312Packages; [
    ipython
    jupyter
    notebook
    pandas
    numpy
    matplotlib
    scipy
    scikit-learn
    torch-bin
    torchvision-bin
    torchaudio-bin
    transformers
    datasets
    tokenizers
    accelerate
    ninja
    setuptools
    wheel
    pip
  ];

in pkgs.mkShell {
  buildInputs = with pkgs; [
    # Base Python
    python312
    python312Packages.pip
    python312Packages.virtualenv
    
    # Development tools
    git
    gcc
    cmake
    pkg-config
    
    # CUDA toolkit and related packages
    cudatoolkit
  ] ++ cuda-common-pkgs ++ python-ml-pkgs;

  shellHook = ''
    # Create and activate virtual environment if it doesn't exist

    # Declared Paths and files
    VENV_DIR="$HOME/.python-devshell-venv"
    REQUIREMENTS="/etc/nixos/dev-shells/requirements.txt"

    if [ ! -d "$VENV_DIR" ]; then
      python -m venv "$VENV_DIR"
      source "$VENV_DIR/bin/activate"

      # Install all required packages
      pip install --upgrade pip
      pip install $REQUIREMENTS

      echo "Initial package installation complete!"
    else
      source "$VENV_DIR/bin/activate"
    fi

    # Set environment variables for CUDA
    export CUDA_PATH="${pkgs.cudatoolkit}"
    export LD_LIBRARY_PATH="$CUDA_PATH/lib:${pkgs.cudaPackages.cudnn}/lib:$LD_LIBRARY_PATH"
    export CUDA_HOME="$CUDA_PATH"
    export EXTRA_LDFLAGS="-L/lib -L${pkgs.cudatoolkit}/lib"
    export CUDA_TOOLKIT_ROOT_DIR=${pkgs.cudatoolkit}
    export CUDNN_PATH=${pkgs.cudaPackages.cudnn}

    # Set PIP_PREFIX to keep packages isolated
    export PIP_PREFIX="$VENV_DIR"
    export PYTHONPATH="$VENV_DIR/lib/python3.*/site-packages:$PYTHONPATH"
    export PATH="$VENV_DIR/bin:$PATH"

    echo "Python CUDA development environment activated!"
    echo "Python version: $(python --version)"
    echo "Pip version: $(pip --version)"
    echo "CUDA version: $(nvcc --version | grep release | awk '{print $6}' | cut -c2-)"
    echo "Virtual environment: $VENV_DIR"
  '';
}


