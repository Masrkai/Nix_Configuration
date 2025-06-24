{ config, pkgs, lib, ... }:

let
  # Create a dedicated Python environment with CUDA support
  pythonWithCuda = pkgs.python3.buildEnv.override {
    extraLibs = with pkgs.python3Packages; [
      # Core Python packages
      pip
      setuptools
      wheel
      
      # CUDA-related packages
      numpy
      torch-bin  # Pre-built PyTorch with CUDA support
      
      # UV package manager
      (pkgs.python3Packages.buildPythonPackage rec {
        pname = "uv";
        version = "0.1.20";  # Adjust version as needed
        
        src = pkgs.fetchPypi {
          inherit pname version;
          sha256 = "sha256-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx";  # Replace with actual hash
        };
        
        doCheck = false;
        propagatedBuildInputs = with pkgs.python3Packages; [ pip setuptools wheel ];
      })
    ];
  };
  
  # Create a shell script to launch the Python environment
  pythonCudaScript = pkgs.writeScriptBin "python-cuda-shell" ''
    #!${pkgs.bash}/bin/bash
    
    # Create persistent storage directory if it doesn't exist
    PYTHON_ENV_DIR="$HOME/.local/share/nix-python-cuda-env"
    mkdir -p $PYTHON_ENV_DIR
    
    # Initialize UV if not already done
    if [ ! -f "$PYTHON_ENV_DIR/.uv-initialized" ]; then
      echo "Initializing UV package manager..."
      ${pythonWithCuda}/bin/uv --version
      touch "$PYTHON_ENV_DIR/.uv-initialized"
    fi
    
    # Set up environment variables for CUDA
    export CUDA_HOME=${pkgs.cudaPackages.cuda_cudart}
    export LD_LIBRARY_PATH=${pkgs.cudaPackages.cuda_cudart}/lib:${pkgs.cudaPackages.cuda_cccl}/lib:${pkgs.cudaPackages.libcublas}/lib:$LD_LIBRARY_PATH
    export PATH=$CUDA_HOME/bin:$PATH
    
    # Set up nix-ld paths for libraries
    export NIX_LD_LIBRARY_PATH=${lib.makeLibraryPath config.programs.nix-ld.libraries}
    export NIX_LD=${pkgs.stdenv.cc.bintools.dynamicLinker}
    
    # Set up persistent Python environment
    export PYTHONUSERBASE="$PYTHON_ENV_DIR"
    export PATH="$PYTHONUSERBASE/bin:$PATH"
    
    # Function to install requirements.txt with UV
    install_requirements() {
      if [ -f "$1" ]; then
        echo "Installing packages from $1 using UV..."
        ${pythonWithCuda}/bin/uv pip install --user -r "$1"
      else
        echo "File not found: $1"
      fi
    }
    
    # Add helper functions
    install_package() {
      echo "Installing package $1 using UV..."
      ${pythonWithCuda}/bin/uv pip install --user "$1"
    }
    
    # Parse arguments
    if [ "$1" = "install" ] && [ -n "$2" ]; then
      if [ "$2" = "-r" ] && [ -n "$3" ]; then
        install_requirements "$3"
        exit 0
      else
        install_package "$2"
        exit 0
      fi
    elif [ "$1" = "shell" ]; then
      # Launch interactive shell
      echo "Launching Python CUDA shell environment..."
      exec ${pythonWithCuda}/bin/python
    else
      # Default: run Python with arguments
      exec ${pythonWithCuda}/bin/python "$@"
    fi
  '';
  
in {
  environment.systemPackages = with pkgs; [
    # Add the Python CUDA shell script
    pythonCudaScript
    
    # Core CUDA packages
    cudaPackages.cuda_cudart
    cudaPackages.cuda_cccl
    cudaPackages.libcublas
    cudaPackages.cudnn
    
    # Other useful tools
    git
    gcc
  ];
  
  # Make sure nix-ld is enabled (you already have this configured)
  # programs.nix-ld.enable = true;
  
  # Add environment variables to make CUDA findable
  environment.variables = {
    CUDA_PATH = "${pkgs.cudaPackages.cuda_cudart}";
  };
  
  # Optional: Add systemd service to ensure the Python environment persists across reboots
  systemd.user.services.python-cuda-env-init = {
    description = "Initialize Python CUDA Environment";
    wantedBy = [ "default.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pythonCudaScript}/bin/python-cuda-shell install -r /dev/null";
      RemainAfterExit = true;
    };
  };
}