{ nixpkgsConfig ? {} }:

let
  # Import nixpkgs with the necessary configuration
  nixpkgs = import <nixpkgs> {
    config = {
      allowUnfree = true;
      cudaSupport = true;
    } // nixpkgsConfig.config or {};
    overlays = nixpkgsConfig.overlays or [];
  };

  PyVersion = 312;
  pythonSP = pkgs."python${toString PyVersion}";
  pythonPackages = pkgs."python${toString PyVersion}Packages";

  inherit (nixpkgs) pkgs;
  
  # Create a proper library path string
  libraryPath = with pkgs; lib.makeLibraryPath [
    stdenv.cc.cc.lib
    cudatoolkit
    cudaPackages.cudnn
    glib
    zlib
  ];

  # CMake configuration
  cmakeConfig = with pkgs; {
    CMAKE_INSTALL_PREFIX = "/usr/local";
    CMAKE_INSTALL_LIBDIR = "lib";
    CMAKE_INSTALL_INCLUDEDIR = "include";
    CMAKE_INSTALL_BINDIR = "bin";
    CMAKE_INSTALL_DOCDIR = "share/doc";
    CMAKE_INSTALL_MANDIR = "share/man";
    CMAKE_INSTALL_INFODIR = "share/info";
    CMAKE_INSTALL_LOCALEDIR = "share/locale";
    CMAKE_INSTALL_SBINDIR = "sbin";
    CMAKE_INSTALL_LIBEXECDIR = "libexec";
    CMAKE_INSTALL_OLDINCLUDEDIR = "/usr/include";
    CMAKE_EXPORT_NO_PACKAGE_REGISTRY = "ON";
    CMAKE_POLICY_DEFAULT_CMP0025 = "NEW";
    BUILD_TESTING = "OFF";
    CUDA_HOST_COMPILER = "${gcc}/bin/gcc";
    CUDAToolkit_ROOT = "${cudatoolkit}";
    CUDAToolkit_INCLUDE_DIR = "${cudatoolkit}/include";
  };

  # Development tools packages
  dev-tools = with pkgs; [
    git
    gcc
    glibc
    cmake
    pkg-config
    stdenv.cc.cc.lib
    gnumake
    ninja
    ccache            # Speed up compilations
    gdb              # Debugging support
    valgrind         # Memory analysis
    lldb             # Alternative debugger
    rr               # Time-travel debugging
  ];

  # Common CUDA packages
  cuda-common-pkgs = with pkgs.cudaPackages; [
    # nccl             # For distributed training
    cudnn
    # cuda_nvcc
    cuda_cudart
    cudatoolkit
  ];

  # Rest of the package definitions remain the same...
  python-ml-pkgs = with pythonPackages; [
    # Core scientific packages
    pip
    wheel
    scipy
    numpy
    pandas
    sympy
    scikit-learn

    # Development tools
    ipython
    jupyter
    pylint          
    notebook
    jupyterlab      
    # black           
    # mypy            
    # pytest          
    # pytest-cov      
    
    # Visualization
    # matplotlib
    # seaborn         
    # plotly          
    # bokeh           
    
    # Machine Learning
    # torch-bin
    # torchvision-bin
    # torchaudio-bin
    # transformers
    # datasets
    # tokenizers
    # accelerate
    # optuna          
    # tensorboard     
    
    # Data processing
    # dask            
    # numba           
    # h5py            
    # pyarrow         
  ];

  audio-pkgs = with pkgs; [
    pipewire
    wireplumber
    libpulseaudio
    portaudio
    alsa-lib        
    jack2           
  ];

  monitoring-pkgs = with pkgs; [
    htop            
    nvtopPackages.full
    iotop           
    nethogs         
  ];

in pkgs.mkShell {
  buildInputs = with pkgs; [
    # Base Python
    pythonSP
    pythonPackages.pip
    pythonPackages.virtualenv
  ]
  ++ dev-tools
  ++ audio-pkgs
  ++ python-ml-pkgs
  ++ cuda-common-pkgs
  # ++ monitoring-pkgs
  ;

  shellHook = ''
    # Environment configuration
    VENV_DIR="$HOME/.python-devshell-venv"
    REQUIREMENTS="/etc/nixos/dev-shells/requirements.txt"

    # Virtual environment setup
    if [ ! -d "$VENV_DIR" ]; then
      echo "Creating new virtual environment..."
      python -m venv "$VENV_DIR"
      source "$VENV_DIR/bin/activate"

      if [ -f "$REQUIREMENTS" ]; then
        echo "Installing requirements..."
        pip install --upgrade pip
        pip install -r "$REQUIREMENTS"
      else
        echo "Warning: $REQUIREMENTS not found"
      fi

      # Install development tools in venv
      pip install ipdb pytest-xdist memory_profiler line_profiler

      echo "Virtual environment setup complete!"
    else
      source "$VENV_DIR/bin/activate"
    fi

    # CUDA configuration
    export CUDA_PATH="${pkgs.cudatoolkit}"
    export CUDA_HOME="$CUDA_PATH"
    export CUDA_TOOLKIT_ROOT_DIR=${pkgs.cudatoolkit}
    export CUDNN_PATH=${pkgs.cudaPackages.cudnn}

    # Library paths
    export LD_LIBRARY_PATH="${libraryPath}:$LD_LIBRARY_PATH"
    export EXTRA_LDFLAGS="-L/lib -L${pkgs.cudatoolkit}/lib"

    # CMake configuration
    ${builtins.concatStringsSep "\n" (builtins.attrValues (builtins.mapAttrs (name: value: 
      "export ${name}=${value}"
    ) cmakeConfig))}

    # Python environment configuration
    export PIP_PREFIX="$VENV_DIR"
    export PYTHONPATH="$VENV_DIR/lib/python3.*/site-packages:$PYTHONPATH"
    export PATH="$VENV_DIR/bin:$PATH"

    # Development environment configuration
    export PYTHONDONTWRITEBYTECODE=1  
    export PYTHONUNBUFFERED=1         
    export PYTHONASYNCIODEBUG=1       
    
    # Configure ccache
    export CCACHE_DIR="$HOME/.ccache"
    export PATH="${pkgs.ccache}/bin:$PATH"

    # Environment information
    print_section() {
      echo "=== $1 ==="
      shift
      for cmd in "$@"; do
        if command -v $cmd >/dev/null 2>&1; then
          echo "$cmd version: $($cmd --version 2>&1 | head -n1)"
        else
          echo "Warning: $cmd not found in PATH"
        fi
      done
      echo
    }

    print_section "Python Environment" python pip
    print_section "CUDA Tools" nvcc nvidia-smi
    print_section "Development Tools" gcc gdb cmake
    echo "Virtual environment: $VENV_DIR"
    echo "CUDA_HOME: $CUDA_HOME"
    echo "Development shell ready! 🚀"
  '';
}