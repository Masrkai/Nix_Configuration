{ config, lib, pkgs, modulesPath, ... }:

let
  secrets = import ./Sec/secrets.nix;
  unstable = import <unstable> {
    config.allowUnfree = true;
  };
in
{

  nix = {
  settings = {
      experimental-features = [
        #"flakes"
        "nix-command"
      ];

      cores = 12;                       # Restrict builds to use only N cores 0 to use all.
      max-jobs = 4;                     # Limit the number of parallel build jobs.
      sandbox = true;                   # Enable sandboxing if not already enabled (it helps isolate builds).
      builders-use-substitutes = true;  # Prefer cached builds
      system-features = [ "big-parallel" "kvm" ];

      trusted-users =[
        "root"
        "@wheel"
        "masrkai"
      ];

      # Keep fewer generations to reduce memory pressure
      keep-derivations = false;
      keep-outputs = false;
    };
  };

  nixpkgs = {
    overlays = [
      (final: prev: {

        # filterOutX11 = prev.lib.filterAttrs (name: pkg:
        #   !(final.lib.strings.contains "libX11" (toString pkg) ||
        #     final.lib.strings.contains "xset" (toString pkg) ||
        #     final.lib.strings.contains "x11-utils" (toString pkg)))
        #   prev;

        # onnxruntime = final.python3Packages.callPackage ../Programs/python-libs/onnxruntime.nix{};

        metasploit = unstable.metasploit;

        jackett = prev.jackett.overrideAttrs (oldAttrs: {
          doCheck = false;
        });

        wine = prev.wineWowPackages.stableFull.override {
          x11Support = false;
          cupsSupport = false;
          waylandSupport = true;
        };

        ffmpeg = prev.ffmpeg.override {
          withWhisper    = false;
          withSvtav1     = true;
          withAom        =true;
          withTensorflow = false;

          withMetal = false; # Use Metal API on Mac. Unfree and requires manual downloading of files
          withMfx = false; # Hardware acceleration via the deprecated intel-media-sdk/libmfx. Use oneVPL instead (enabled by default) from Intel's oneAPI.

          # withFrei0r    = false;
        };

        ffmpeg-full = prev.ffmpeg-full.override {
          withWhisper    = false;
          withSvtav1     = true;
          withAom        =true;
          withTensorflow = false;

          withMetal = false; # Use Metal API on Mac. Unfree and requires manual downloading of files
          withMfx = false; # Hardware acceleration via the deprecated intel-media-sdk/libmfx. Use oneVPL instead (enabled by default) from Intel's oneAPI.

          # withFrei0r    = false;
        };


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


      })
    ];
    #-------------------------------------------------------------------->
    config = {
      allowUnfree = true;
      allowBroken = false; #! don't enable in production no matter what

      permittedInsecurePackages = [
        "ciscoPacketTracer8-8.2.2"
        "minio-2025-10-15T17-29-55Z"
      ];
    };
  };
}
