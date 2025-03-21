{  lib, pkgs, ...}:

{



  imports = [
    ./env.nix
    ./vscodium.nix
    ./sql-server.nix
  ];

  nixpkgs = {
    overlays = [
      (final: prev: {
        # Top-level package replacements
        torch = prev.torch-bin;
        triton = prev.triton-bin;
        torchaudio = prev.torchaudio-bin;
        torchvision = prev.torchvision-bin;

        pythonPackagesExtensions = [

          (py-final: py-prev: {
            torch = py-final.torch-bin;
            triton = py-final.triton-bin;
            torchaudio = py-final.torchaudio-bin;
            torchvision = py-final.torchvision-bin;
          })

        (py-final: py-prev: {
        # Custom bitsandbytes that works with binary pytorch
          bitsandbytes = py-prev.buildPythonPackage {
            pname = "bitsandbytes";
            version = "0.44.1";
            pyproject = true;

            src = prev.fetchFromGitHub {
              owner = "TimDettmers";
              repo = "bitsandbytes";
              tag = "0.44.1";
              hash = "sha256-yvxD5ymMK5p4Xg7Csx/90mPV3yxUC6QUuF/8BKO2p0k=";
            };

            nativeBuildInputs = [
              prev.cmake
              prev.cudaPackages.cuda_nvcc
            ];

            build-system = [
              py-prev.setuptools
            ];

            buildInputs = [
              # Define CUDA dependencies directly
              prev.cudaPackages.cuda_cccl
              prev.cudaPackages.libcublas
              prev.cudaPackages.libcurand
              prev.cudaPackages.libcusolver
              prev.cudaPackages.libcusparse
              prev.cudaPackages.cuda_cudart
            ];

            cmakeFlags = [
              (prev.lib.cmakeFeature "COMPUTE_BACKEND" "cuda")
            ];
            
            # Pass CUDA_HOME directly
            CUDA_HOME = prev.symlinkJoin {
              name = "cuda-home";
              paths = with prev.cudaPackages; [
                cuda_cudart
                cuda_nvcc
                libcublas
                libcurand
                libcusolver
                libcusparse
                cuda_cccl
              ];
            };
            
            NVCC_PREPEND_FLAGS = [
              "-I${prev.cudaPackages.cuda_cudart.dev}/include"
              "-L${prev.cudaPackages.cuda_cudart.lib}/lib"
            ];

            preBuild = ''
              make -j $NIX_BUILD_CORES
              cd .. # leave /build/source/build
            '';

            dependencies = [
              py-prev.scipy
              py-final.torch-bin
            ];

            doCheck = false;
            pythonImportsCheck = [ "bitsandbytes" ];

            meta = {
              description = "8-bit CUDA functions for PyTorch";
              homepage = "https://github.com/TimDettmers/bitsandbytes";
              license = prev.lib.licenses.mit;
            };
          };
        })
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

        # Compositionally correct extension for huggingface-hub
        (py-final: py-prev: let
          version = "0.29.1";
        in {
          huggingface-hub = py-prev.huggingface-hub.overrideAttrs (oldAttrs: {
            inherit version;
            src = prev.fetchFromGitHub {  # Use prev from outer scope
              owner = "huggingface";
              repo = "huggingface_hub";
              tag = "v${version}";
              # hash = lib.fakeHash;
              hash = "sha256-9G5oq8X5/MtHZAOM7QHoMyRePPFwMe4Wa66y+japxwA=";
            };
            meta = oldAttrs.meta // {
              changelog = "https://github.com/huggingface/huggingface_hub/releases/tag/v${version}";
            };
          });
        })

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        ];


      })
    ];
  };





}