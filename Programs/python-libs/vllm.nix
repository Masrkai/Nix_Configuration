{
  lib,
  stdenv,
  python,
  buildPythonPackage,
  pythonRelaxDepsHook,
  fetchFromGitHub,
  symlinkJoin,
  autoAddDriverRunpath,

  # build system
  packaging,
  setuptools,
  wheel,

  # dependencies
  which,
  ninja,
  cmake,
  setuptools-scm,
  torch,
  outlines,
  psutil,
  ray,
  pandas,
  pyarrow,
  sentencepiece,
  numpy,
  transformers,
  xformers,
  xgrammar,
  numba,
  fastapi,
  uvicorn,
  pydantic,
  aioprometheus,
  pynvml,
  openai,
  pyzmq,
  tiktoken,
  torchaudio,
  torchvision,
  py-cpuinfo,
  lm-format-enforcer,
  prometheus-fastapi-instrumentator,
  cupy,
  gguf,
  einops,
  importlib-metadata,
  partial-json-parser,
  compressed-tensors,
  mistral-common,
  msgspec,
  numactl,
  tokenizers,
  oneDNN,
  blake3,
  depyf,
  opencv-python-headless,
  cachetools,
  llguidance,
  python-json-logger,
  python-multipart,
  llvmPackages,

  cudaSupport ? torch.cudaSupport,
  cudaPackages ? { },
  rocmSupport ? torch.rocmSupport,
  rocmPackages ? { },
  gpuTargets ? [ ],
}:

let
  inherit (lib)
    lists
    strings
    trivial
    ;

  inherit (cudaPackages) flags;

  shouldUsePkg =
    pkg: if pkg != null && lib.meta.availableOn stdenv.hostPlatform pkg then pkg else null;

  # see CMakeLists.txt, grepping for GIT_TAG near cutlass
  # https://github.com/vllm-project/vllm/blob/v${version}/CMakeLists.txt
  cutlass = fetchFromGitHub {
    owner = "NVIDIA";
    repo = "cutlass";
    tag = "v3.9.2";
    hash = "sha256-teziPNA9csYvhkG5t2ht8W8x5+1YGGbHm8VKx4JoxgI=";
  };

  flashmla = stdenv.mkDerivation {
    pname = "flashmla";
    # https://github.com/vllm-project/FlashMLA/blob/${src.rev}/setup.py
    version = "1.0.0";

    # grep for GIT_TAG in the following file
    # https://github.com/vllm-project/vllm/blob/v${version}/cmake/external_projects/flashmla.cmake
    src = fetchFromGitHub {
      owner = "vllm-project";
      repo = "FlashMLA";
      rev = "575f7724b9762f265bbee5889df9c7d630801845";
      hash = "sha256-8WrKMl0olr0nYV4FRJfwSaJ0F5gWQpssoFMjr9tbHBk=";
    };

    dontConfigure = true;

    # flashmla normally relies on `git submodule update` to fetch cutlass
    buildPhase = ''
      ls -al
      rm -rf csrc/cutlass
      ln -sf ${cutlass} csrc/cutlass
    '';

    installPhase = ''
      cp -rva . $out
    '';
  };

  vllm-flash-attn = stdenv.mkDerivation {
    pname = "vllm-flash-attn";
    # https://github.com/vllm-project/flash-attention/blob/${src.rev}/vllm_flash_attn/__init__.py
    version = "2.7.2.post1";

    # grep for GIT_TAG in the following file
    # https://github.com/vllm-project/vllm/blob/v${version}/cmake/external_projects/vllm_flash_attn.cmake
    src = fetchFromGitHub {
      owner = "vllm-project";
      repo = "flash-attention";
      rev = "dc9d410b3e2d6534a4c70724c2515f4def670a22";
      hash = "sha256-ZQ0bOBIb+8IMmya8dmimKQ17KTBplX81IirdnBJpX5M=";
    };

    dontConfigure = true;

    # vllm-flash-attn normally relies on `git submodule update` to fetch cutlass
    buildPhase = ''
      rm -rf csrc/cutlass
      ln -sf ${cutlass} csrc/cutlass
    '';

    installPhase = ''
      cp -rva . $out
    '';
  };

  cpuSupport = !cudaSupport && !rocmSupport;

  # https://github.com/pytorch/pytorch/blob/v2.7.0/torch/utils/cpp_extension.py#L2343-L2345
  supportedTorchCudaCapabilities =
    let
      real = [
        "3.5"
        "3.7"
        "5.0"
        "5.2"
        "5.3"
        "6.0"
        "6.1"
        "6.2"
        "7.0"
        "7.2"
        "7.5"
        "8.0"
        "8.6"
        "8.7"
        "8.9"
        "9.0"
        "9.0a"
        "10.0"
        "10.0a"
        "10.1"
        "10.1a"
        "12.0"
        "12.0a"
      ];
      ptx = lists.map (x: "${x}+PTX") real;
    in
    real ++ ptx;

  # NOTE: The lists.subtractLists function is perhaps a bit unintuitive. It subtracts the elements
  #   of the first list *from* the second list. That means:
  #   lists.subtractLists a b = b - a

  # For CUDA
  supportedCudaCapabilities = lists.intersectLists flags.cudaCapabilities supportedTorchCudaCapabilities;
  unsupportedCudaCapabilities = lists.subtractLists supportedCudaCapabilities flags.cudaCapabilities;

  isCudaJetson = cudaSupport && cudaPackages.flags.isJetsonBuild;

  # Use trivial.warnIf to print a warning if any unsupported GPU targets are specified.
  gpuArchWarner =
    supported: unsupported:
    trivial.throwIf (supported == [ ]) (
      "No supported GPU targets specified. Requested GPU targets: "
      + strings.concatStringsSep ", " unsupported
    ) supported;

  # Create the gpuTargetString.
  gpuTargetString = strings.concatStringsSep ";" (
    if gpuTargets != [ ] then
      # If gpuTargets is specified, it always takes priority.
      gpuTargets
    else if cudaSupport then
      gpuArchWarner supportedCudaCapabilities unsupportedCudaCapabilities
    else if rocmSupport then
      rocmPackages.clr.gpuTargets
    else
      throw "No GPU targets specified"
  );

  mergedCudaLibraries = with cudaPackages; [
    cuda_cudart # cuda_runtime.h, -lcudart
    cuda_cccl
    libcusparse # cusparse.h
    libcusolver # cusolverDn.h
    cuda_nvtx
    cuda_nvrtc
    libcublas
  ];

  # Some packages are not available on all platforms
  nccl = shouldUsePkg (cudaPackages.nccl or null);

  getAllOutputs = p: [
    (lib.getBin p)
    (lib.getLib p)
    (lib.getDev p)
  ];

in

buildPythonPackage rec {
  pname = "vllm";
  version = "0.9.0";
  pyproject = true;

  stdenv = torch.stdenv;

  src = fetchFromGitHub {
    owner = "vllm-project";
    repo = "vllm";
    tag = "v${version}";
    hash = "sha256-dkkmvr7K5CA1gDTpa2RugzcME9f3CarCPHrAb2LoPIM=";
  };

  patches = [
    ./patches/vllm/0002-setup.py-nix-support-respect-cmakeFlags.patch
    ./patches/vllm/0003-propagate-pythonpath.patch
    ./patches/vllm/0004-drop-lsmod.patch
  ];

  # Ignore the python version check because it hard-codes minor versions and
  # lags behind `ray`'s python interpreter support
  postPatch =
    ''
      substituteInPlace CMakeLists.txt \
        --replace-fail \
          'set(PYTHON_SUPPORTED_VERSIONS' \
          'set(PYTHON_SUPPORTED_VERSIONS "${lib.versions.majorMinor python.version}"'
    ''
    + lib.optionalString (nccl == null) ''
      # On platforms where NCCL is not supported (e.g. Jetson), substitute Gloo (provided by Torch)
      substituteInPlace vllm/distributed/parallel_state.py \
        --replace-fail '"nccl"' '"gloo"'
    '';

  nativeBuildInputs =
    [
      cmake
      ninja
      pythonRelaxDepsHook
      which
    ]
    ++ lib.optionals rocmSupport [
      rocmPackages.hipcc
    ]
    ++ lib.optionals cudaSupport [
      cudaPackages.cuda_nvcc
      autoAddDriverRunpath
    ]
    ++ lib.optionals isCudaJetson [
      cudaPackages.autoAddCudaCompatRunpath
    ];

  build-system = [
    packaging
    setuptools
    wheel
  ];

  buildInputs =
    [
      setuptools-scm
      torch
    ]
    ++ lib.optionals cpuSupport [
      oneDNN
    ]
    ++ lib.optionals (cpuSupport && stdenv.isLinux) [
      numactl
    ]
    ++ lib.optionals cudaSupport (
      mergedCudaLibraries
      ++ (with cudaPackages; [
        nccl
        cudnn
        libcufile
      ])
    )
    ++ lib.optionals rocmSupport (
      with rocmPackages;
      [
        clr
        rocthrust
        rocprim
        hipsparse
        hipblas
      ]
    )
    ++ lib.optionals stdenv.cc.isClang [
      llvmPackages.openmp
    ];

  dependencies =
    [
      aioprometheus
      blake3
      cachetools
      depyf
      fastapi
      llguidance
      lm-format-enforcer
      numpy
      openai
      opencv-python-headless
      outlines
      pandas
      prometheus-fastapi-instrumentator
      psutil
      py-cpuinfo
      pyarrow
      pydantic
      python-json-logger
      python-multipart
      pyzmq
      ray
      sentencepiece
      tiktoken
      tokenizers
      msgspec
      gguf
      einops
      importlib-metadata
      partial-json-parser
      compressed-tensors
      mistral-common
      torch
      torchaudio
      torchvision
      transformers
      uvicorn
      xformers
      xgrammar
      numba
    ]
    ++ uvicorn.optional-dependencies.standard
    ++ aioprometheus.optional-dependencies.starlette
    ++ lib.optionals cudaSupport [
      cupy
      pynvml
    ];

  dontUseCmakeConfigure = true;
  cmakeFlags =
    [
      (lib.cmakeFeature "FETCHCONTENT_SOURCE_DIR_CUTLASS" "${lib.getDev cutlass}")
      (lib.cmakeFeature "FLASH_MLA_SRC_DIR" "${lib.getDev flashmla}")
      (lib.cmakeFeature "VLLM_FLASH_ATTN_SRC_DIR" "${lib.getDev vllm-flash-attn}")
    ]
    ++ lib.optionals cudaSupport [
      (lib.cmakeFeature "TORCH_CUDA_ARCH_LIST" "${gpuTargetString}")
      (lib.cmakeFeature "CUTLASS_NVCC_ARCHS_ENABLED" "${cudaPackages.flags.cmakeCudaArchitecturesString}")
      (lib.cmakeFeature "CUDA_TOOLKIT_ROOT_DIR" "${symlinkJoin {
        name = "cuda-merged-${cudaPackages.cudaMajorMinorVersion}";
        paths = builtins.concatMap getAllOutputs mergedCudaLibraries;
      }}")
      (lib.cmakeFeature "CAFFE2_USE_CUDNN" "ON")
      (lib.cmakeFeature "CAFFE2_USE_CUFILE" "ON")
      (lib.cmakeFeature "CUTLASS_ENABLE_CUBLAS" "ON")
    ]
    ++ lib.optionals cpuSupport [
      (lib.cmakeFeature "FETCHCONTENT_SOURCE_DIR_ONEDNN" "${lib.getDev oneDNN}")
    ];

  env =
    lib.optionalAttrs cudaSupport {
      VLLM_TARGET_DEVICE = "cuda";
      CUDA_HOME = "${lib.getDev cudaPackages.cuda_nvcc}";
    }
    // lib.optionalAttrs rocmSupport {
      VLLM_TARGET_DEVICE = "rocm";
      # Otherwise it tries to enumerate host supported ROCM gfx archs, and that is not possible due to sandboxing.
      PYTORCH_ROCM_ARCH = lib.strings.concatStringsSep ";" rocmPackages.clr.gpuTargets;
      ROCM_HOME = "${rocmPackages.clr}";
    }
    // lib.optionalAttrs cpuSupport {
      VLLM_TARGET_DEVICE = "cpu";
    };

  preConfigure = ''
    # See: https://github.com/vllm-project/vllm/blob/v0.7.1/setup.py#L75-L109
    # There's also NVCC_THREADS but Nix/Nixpkgs doesn't really have this concept.
    export MAX_JOBS="$NIX_BUILD_CORES"
  '';

  pythonRelaxDeps = true;

  pythonImportsCheck = [ "vllm" ];

  # updates the cutlass fetcher instead
  passthru.skipBulkUpdate = true;

  meta = {
    description = "High-throughput and memory-efficient inference and serving engine for LLMs";
    changelog = "https://github.com/vllm-project/vllm/releases/tag/v${version}";
    homepage = "https://github.com/vllm-project/vllm";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [
      happysalada
      lach
    ];
    badPlatforms = [
      # CMake Error at cmake/cpu_extension.cmake:78 (find_isa):
      # find_isa Function invoked with incorrect arguments for function named:
      # find_isa
      "x86_64-darwin"
    ];
  };
}