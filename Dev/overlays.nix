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
          # onnxruntime = final.python3Packages.callPackage ../Programs/python-libs/onnxruntime.nix{};

          pythonPackagesExtensions = [
              (py-final: py-prev: {
                trl = py-final.callPackage ../Programs/python-libs/trl.nix{ };
                tyro = py-final.callPackage ../Programs/python-libs/tyro.nix{ };
                datasets = py-final.callPackage ../Programs/python-libs/datasets.nix{ };
                smolagents = py-final.callPackage ../Programs/python-libs/smolagents.nix{};
                onnxruntime = py-final.callPackage ../Programs/python-libs/onnxruntime.nix{};

                # hf-xet = py-final.callPackage ../Programs/python-libs/hf-xet.nix{};
                # huggingface-hub = py-final.callPackage ../Programs/python-libs/huggingface-hub.nix{};

                # llama-cpp-python =  py-final.callPackage ../Programs/python-libs/llama-cpp-python.nix{ };
                cut-cross-entropy = py-final.callPackage ../Programs/python-libs/cut-cross-entropy.nix{ };

                vllm = py-final.callPackage ../Programs/python-libs/vllm.nix{ };
                keras = py-final.callPackage ../Programs/python-libs/keras.nix{ };
                # xformers = py-final.callPackage ../Programs/python-libs/xformers.nix{ };
                flash-attn = py-final.callPackage ../Programs/python-libs/flash-attn.nix{ };

                unsloth = py-final.callPackage ../Programs/python-libs/unsloth/unsloth.nix{ };
                unsloth-zoo = py-final.callPackage ../Programs/python-libs/unsloth/unsloth-zoo.nix{ };

                fairseq2 = py-final.callPackage ../Programs/python-libs/fairseq2.nix{ };


                # Jax is a complicated situation, in case of the basic setup fron nixpkgs
                # it will fail tests so it will maybe brick installs so at the very least
                # overlay "doCheck = false;" to skip tests

                # jax = py-prev.jax.overrideAttrs (oldAttrs: {
                #   doCheck = false;
                # });

                # otherwise my informed choice of using a wheel here saves me so much building time and compute
                jax = py-final.callPackage ../Programs/python-libs/jax.nix{ };
                jaxlib = py-prev.jaxlib-bin;

                #> torch to torch-bin
                torch = py-prev.torch-bin;
                torchaudio = py-final.torchaudio-bin;
                torchvision = py-final.torchvision-bin;
              })

          ];

        }
      )

    ];
  };
}
