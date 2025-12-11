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
          onnxruntime = final.python3Packages.callPackage ../Programs/python-libs/onnxruntime.nix{};

          pythonPackagesExtensions = [
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

            (py-final: py-prev: {
                jaxlib = py-prev.jaxlib-bin;

                #> torch to torch-bin
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
            })
          ];

        }
      )

    ];
  };
}