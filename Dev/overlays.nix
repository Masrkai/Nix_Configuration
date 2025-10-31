{pkgs, config, ...}:

let
  secrets = import ../Sec/secrets.nix;
  unstable = import <unstable> {
    # config.allowUnfree = true;
    config = config.nixpkgs.config;
    overlays = [];
    };

in

{
  nixpkgs = {
    overlays = [

      (final: prev: {

          pythonPackagesExtensions = [

              #* Custom made python packages!

              (python-final: python-prev: {
                trl = python-final.callPackage ../Programs/python-libs/trl.nix{ };
                tyro = python-final.callPackage ../Programs/python-libs/tyro.nix{ };
                datasets = python-final.callPackage ../Programs/python-libs/datasets.nix{ };
                smolagents = python-final.callPackage ../Programs/python-libs/smolagents.nix{};
                onnxruntime = python-final.callPackage ../Programs/python-libs/onnxruntime.nix{};

                hf-xet = python-final.callPackage ../Programs/python-libs/hf-xet.nix{};
                huggingface-hub = python-final.callPackage ../Programs/python-libs/huggingface-hub.nix{};

                # llama-cpp-python =  python-final.callPackage ../Programs/python-libs/llama-cpp-python.nix{ };
                cut-cross-entropy = python-final.callPackage ../Programs/python-libs/cut-cross-entropy.nix{ };

                vllm = python-final.callPackage ../Programs/python-libs/vllm.nix{ };
                keras = python-final.callPackage ../Programs/python-libs/keras.nix{ };
                # xformers = python-final.callPackage ../Programs/python-libs/xformers.nix{ };
                flash-attn = python-final.callPackage ../Programs/python-libs/flash-attn.nix{ };

                unsloth = python-final.callPackage ../Programs/python-libs/unsloth/unsloth.nix{ };
                unsloth-zoo = python-final.callPackage ../Programs/python-libs/unsloth/unsloth-zoo.nix{ };

                fairseq2 = python-final.callPackage ../Programs/python-libs/fairseq2.nix{ };

                jax = python-final.callPackage ../Programs/python-libs/jax.nix{ };
              })

          #?????????????????????????????????????????????????????????????????????????????????
              (self: super: {
              # flax = unstable.python3Packages.flax;
              # vllm = unstable.python3Packages.vllm;
                # jax = unstable.python3Packages.jax;
                # jaxlib = unstable.python3Packages.jaxlib-bin;

                # jax = super.jax;
                jaxlib = super.jaxlib-bin;
                # jaxlib = unstable.python3Packages.jaxlib-bin;
              })

          #?????????????????????????????????????????????????????????????????????????????????

            (py-final: py-prev: {

                #> torch to torch-bin
                # torch = py-final.torch-bin
  
                # # // {
                # #   cudaSupport = true;
                # #   rocmSupport = false;
                # #   cudaPackages = final.cudaPackages;
                # #   # cudaCapabilities =
                # #   #                     # prev.torch.cudaCapabilities;
                # #   #                     [ "8.0" "8.6" ] ; # Adjust for your specific GPU
                # #   #                     # prev.torch.supportedTorchCudaCapabilities;
                # # }
                # ;

                torch = py-prev.torch-bin.overrideAttrs (oldAttrs: {
                            passthru = (oldAttrs.passthru or {}) // {
                              # Add the missing attributes that torch-dependent packages expect
                              cudaPackages     = final.cudaPackages;
                              cudaSupport      = final.config.cudaSupport or false;
                              cudaCapabilities = final.config.cudaCapabilities or [];

                              # Preserve any existing passthru attributes from torch-bin
                            } // (oldAttrs.passthru or {});
                          });


                torchaudio = py-final.torchaudio-bin;
                torchvision = py-final.torchvision-bin;

                # #*****************************************
                # triton = py-final.triton-bin;

            #>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

                # sentence-transformers = py-prev.sentence-transformers.overridePythonAttrs (old: {
                #   # Add Pillow to dependencies
                #   dependencies = old.dependencies ++ [ py-prev.pillow ];

                #   # Disable runtime dependency check for Pillow
                #   disabledRuntimeDependencies = (old.disabledRuntimeDependencies or []) ++ [ "pillow" ];
                # });
            })


          #?????????????????????????????????????????????????????????????????????????????????


            #>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

                # (py-final: py-prev: let
                #   version = "0.32.3";
                # in {
                #   huggingface-hub = py-prev.huggingface-hub.overrideAttrs (oldAttrs: {
                #     inherit version;
                #     src = prev.fetchFromGitHub {
                #       owner = "huggingface";
                #       repo = "huggingface_hub";
                #       tag = "v${version}";
                #       hash = "sha256-sz+n1uoWrSQPqJFiG/qCT6b4r08kD9MsoPZXbfWNB2o=";
                #     };
                #     meta = oldAttrs.meta // {
                #       changelog = "https://github.com/huggingface/huggingface_hub/releases/tag/v${version}";
                #     };
                #   });
                # })

            #>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

                # Tokenizers override
                # (py-final: py-prev: let
                #       version = "0.21.1";
                #       pname = "tokenizers";
                #       newSrc = prev.fetchFromGitHub {
                #         owner = "huggingface";
                #         repo = "tokenizers";
                #         tag = "v${version}";
                #         # hash = lib.fakeHash;

                #         hash = "sha256-3S7ZCaZnnwyNjoZ4Y/q3ngQE2MIm2iyCCjYAkdMVG2A=";
                #       };
                #   in{

                #       tokenizers = py-prev.tokenizers.overridePythonAttrs (oldAttrs: rec {

                #         # 1) Fetch the new v0.21.1 source with py-prev, not prev
                #         src = newSrc;

                #         # 2) Point to the python bindings subdirectory
                #         sourceRoot = "${src.name}/bindings/python";

                #         # 3) Disable the correctly‐named mismatch test
                #         disabledTests = oldAttrs.disabledTests ++ [
                #           "test_continuing_prefix_trainer_mismatch"
                #         ];

                #         # 4) Symlink tests/data → data so files are found under data/big.txt
                #         postUnpack = oldAttrs.postUnpack + ''
                #           ln -s $sourceRoot/tests/data $sourceRoot/data
                #         '';

                #         # 5) Vendored cargo deps (with the updated hash you already discovered)
                #         cargoDeps = prev.rustPlatform.fetchCargoVendor {
                #           inherit version pname src sourceRoot;
                #           hash = "sha256-wJotxM5mebmSTzOHfmHVNIN6pMX5Zv0dsUJtoT7rHA8=";
                #         };

                #         # 6) Update metadata
                #         meta = oldAttrs.meta // {
                #           changelog = "https://github.com/huggingface/tokenizers/releases/tag/v0.21.1";
                #         };
                #       });
                #     })

            #>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

                # Transformers override
                # (py-final: py-prev: let
                #   version = "4.51.0";
                # in {
                #   transformers = py-prev.transformers.overridePythonAttrs (oldAttrs: {
                #     inherit version;
                #     src = prev.fetchFromGitHub {
                #       owner = "huggingface";
                #       repo = "transformers";
                #       tag = "v${version}";
                #       hash = "sha256-dnVpc6fm1SYGcx7FegpwVVxUY6XRlsxLs5WOxYv11y8=";
                #     };
                #     meta = oldAttrs.meta // {
                #       changelog = "https://github.com/huggingface/transformers/releases/tag/v${version}";
                #     };
                #   });
                # })

            #>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


          #?????????????????????????????????????????????????????????????????????????????????

          ];
        }
      )

    ];
  };
}