{ config, pkgs, lib, ... }:

{
  #> Load nvidia driver for Xorg and Wayland
  services.xserver = {
    videoDrivers = ["nvidia"];
    screenSection = ''
    option "TearFree" "true"
    option "VariableRefresh" "true"
    '';
  };

  # # Add this to your configuration.nix or home.nix
  # programs.nix-ld = {
  #   enable = true;

  #   # Libraries needed for Flutter Linux development
  #   libraries = with pkgs; [
  #     # Build tools
  #     cmake
  #     clang
  #     ninja
  #     pkg-config

  #     # C/C++ development essentials
  #     stdenv.cc.cc.lib

  #     glibc
  #     libgcc
  #     gcc.cc.lib  # instead of stdenv.cc.cc.lib

  #     # CRITICAL: C++ standard library - this was missing!
  #     libcxx  # Alternative C++ stdlib

  #     # Clang/LLVM libraries and runtime
  #     llvmPackages.clang
  #     llvmPackages.libcxx
  #     llvmPackages.libclang
  #     llvmPackages.compiler-rt


  #     # Common native libraries
  #     zlib
  #     zstd
  #     xz
  #     bzip2
  #     openssl
  #     libxml2
  #     curl

  #     # Additional libraries that might be needed
  #     libdeflate
  #     systemd
  #     util-linux
  #     acl
  #     attr
  #   ];
  # };




  boot = lib.mkMerge [
    {
      initrd.kernelModules = [
      "nvidia" "nvidia_drm" "nvidia_uvm" "nvidia_modeset"
      ];

      kernelModules = [
      "nvidia" "nvidia_drm" "nvidia_uvm" "nvidia_modeset"
      ];

      kernelParams = [
      "pci=realloc=on"

      "nvidia-drm.modeset=1"
      "NVreg_PreserveVideoMemoryAllocations=1"
      "nvidia.NVreg_TemporaryFilePath=/var/tmp"

      # Additional parameters for better performance and stability
      "nvidia.NVreg_UsePageAttributeTable=1"
      "nvidia.NVreg_EnableResizableBAR=1"
      ];

      # Blacklist specific kernel modules
      blacklistedKernelModules = [
      "nouveau"                    # Blacklist open-source NVIDIA driver
      "nvidiafb"
      "nvidia_wmi_ec_backlight"
      ];
    }
  ];

  #! Enable OpenGL
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    # extraPackages = with pkgs; [
    #   libvdpau-va-gl
    # ];
  };

  nix.settings = lib.mkMerge [
    {
      substituters = [
        # "https://cuda-maintainers.cachix.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        # "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    }
  ];

  nixpkgs = {
    config = {
      cudaSupport = true;
      cudaForwardCompat = false;
    };
  };

  hardware.nvidia = {
    open = false;
    nvidiaSettings = true;
    videoAcceleration = true;
    modesetting.enable = true;
    dynamicBoost.enable = true;
    powerManagement.enable = true;        # because there is no other GPU to handle desktop
    forceFullCompositionPipeline = false;  # Better screen tearing prevention
    package =
      # config.boot.kernelPackages.nvidiaPackages.latest                           #* 6.14 (since writing this comment)

      #! Manually pin pointed
      config.boot.kernelPackages.nvidiaPackages.mkDriver {
        version = "570.86.16";                                                 #? 6.13
        sha256_64bit = "sha256-RWPqS7ZUJH9JEAWlfHLGdqrNlavhaR1xMyzs8lJhy9U=";
        openSha256 = "sha256-DuVNA63+pJ8IB7Tw2gM4HbwlOh1bcDg2AN2mbEU9VPE=";
        settingsSha256 = "sha256-9rtqh64TyhDF5fFAYiWl3oDHzKJqyOW3abpcf2iNRT8=";
        usePersistenced = false;
      }
      ;
  };

  # Add CUDA toolkit to system packages
  environment = lib.mkMerge [

    {
      systemPackages = with pkgs; [

          #? CUDA
          # magma

          cudatoolkit

          cudaPackages.nccl
          cudaPackages.cuda_nvcc

          cudaPackages.cudnn
          cudaPackages.libnpp
          cudaPackages.cuda_cccl
          cudaPackages.cuda_nvcc
          cudaPackages.cuda_cudart

          cudaPackages.cuda_opencl

          #? Diagnostics
          clinfo     # OpenCL information
          glxinfo    # GLX diagnostics
          libva-utils  # VA-API diagnostics
          vulkan-tools  # Vulkan utilities

          #? Gaming
          mangohud

          #? videoAcceleration
          libva-vdpau-driver
          vaapiVdpau
          nv-codec-headers-12
      ];

    }
  ];

}