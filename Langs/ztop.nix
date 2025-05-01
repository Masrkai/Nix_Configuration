{  lib, pkgs, ...}:

let
  secrets = import ../Sec/secrets.nix;
in
{

  programs.git = {
    enable = true;
    lfs.enable = true;

    config = {
      # Set your global git configuration here
      user.name = "Masrkai";
      user.email = secrets.Email;
      # Add any other git config options you want
      init.defaultBranch = "main";
      # You can add more git configurations here
    };
  };



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

          # Override open-webui to use python312
          # open-webui = prev.open-webui.override {
          #   python311 = prev.python312;
          # };

          # # Override open-webui to use python312
          # blender = prev.blender.override {
          #   python311 = prev.python312;
          # };



          # blender = prev.blender.override {
          #   # Override the python3Packages to use python 3.12
          #   python3Packages = final.python312Packages;
          # };


        pythonPackagesExtensions = [



          (py-final: py-prev: {

            #* Override torch with torch-bin and add missing CUDA attributes
            torch = py-final.torch-bin // {
              cudaSupport = true;
              cudaCapabilities = [ "8.0" "8.6" ]; # Adjust for your specific GPU
              cudaPackages = final.cudaPackages;
            };


            triton = py-final.triton-bin;
            torchaudio = py-final.torchaudio-bin;
            torchvision = py-final.torchvision-bin;


          #>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

            sentence-transformers = py-prev.sentence-transformers.overridePythonAttrs (old: {
              # Add Pillow to dependencies
              dependencies = old.dependencies ++ [ py-prev.pillow ];

              # Disable runtime dependency check for Pillow
              disabledRuntimeDependencies = (old.disabledRuntimeDependencies or []) ++ [ "pillow" ];
            });

          #>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


            #! Custom bitsandbytes that works with binary pytorch
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
            #>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
          })
        ];

        python312PackagesExtensions = [
              # Huggingface Hub override
              (py-final: py-prev: let
                version = "0.30.0";
              in {
                huggingface-hub = py-prev.huggingface-hub.overrideAttrs (oldAttrs: {
                  inherit version;
                  src = prev.fetchFromGitHub {
                    owner = "huggingface";
                    repo = "huggingface_hub";
                    tag = "v${version}";
                    hash = "sha256-sz+n1uoWrSQPqJFiG/qCT6b4r08kD9MsoPZXbfWNB2o=";
                  };
                  meta = oldAttrs.meta // {
                    changelog = "https://github.com/huggingface/huggingface_hub/releases/tag/v${version}";
                  };
                });
              })

              # Tokenizers override
              (py-final: py-prev: let
                    version = "0.21.1";
                    pname = "tokenizers";
                    newSrc = prev.fetchFromGitHub {
                      owner = "huggingface";
                      repo = "tokenizers";
                      tag = "v${version}";
                      # hash = lib.fakeHash;

                      hash = "sha256-3S7ZCaZnnwyNjoZ4Y/q3ngQE2MIm2iyCCjYAkdMVG2A=";
                    };
                in{

                    tokenizers = py-prev.tokenizers.overridePythonAttrs (oldAttrs: rec {

                      # 1) Fetch the new v0.21.1 source with py-prev, not prev
                      src = newSrc;

                      # 2) Point to the python bindings subdirectory
                      sourceRoot = "${src.name}/bindings/python";

                      # 3) Disable the correctly‐named mismatch test
                      disabledTests = oldAttrs.disabledTests ++ [
                        "test_continuing_prefix_trainer_mismatch"
                      ];

                      # 4) Symlink tests/data → data so files are found under data/big.txt
                      postUnpack = oldAttrs.postUnpack + ''
                        ln -s $sourceRoot/tests/data $sourceRoot/data
                      '';

                      # 5) Vendored cargo deps (with the updated hash you already discovered)
                      cargoDeps = prev.rustPlatform.fetchCargoTarball {
                        inherit version pname src sourceRoot;
                        hash = "sha256-wJotxM5mebmSTzOHfmHVNIN6pMX5Zv0dsUJtoT7rHA8=";
                      };

                      # 6) Update metadata
                      meta = oldAttrs.meta // {
                        changelog = "https://github.com/huggingface/tokenizers/releases/tag/v0.21.1";
                      };
                    });
                  })

              # Transformers override
              (py-final: py-prev: let
                version = "4.51.0";
              in {
                transformers = py-prev.transformers.overridePythonAttrs (oldAttrs: {
                  inherit version;
                  src = prev.fetchFromGitHub {
                    owner = "huggingface";
                    repo = "transformers";
                    tag = "v${version}";
                    hash = "sha256-dnVpc6fm1SYGcx7FegpwVVxUY6XRlsxLs5WOxYv11y8=";
                  };
                  meta = oldAttrs.meta // {
                    changelog = "https://github.com/huggingface/transformers/releases/tag/v${version}";
                  };
                });
              })
        ];

            # Very important: Override python312 itself
            python312 = prev.python312.override {
              packageOverrides = prev.lib.composeManyExtensions final.python312PackagesExtensions;
            };

          })


    ];
  };





}