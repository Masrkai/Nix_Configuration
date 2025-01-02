{ config, pkgs, lib, ... }:

{
  # Enable OpenGL
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      vulkan-loader
      vulkan-tools
      libva-vdpau-driver
     ];
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];

  nixpkgs.config = lib.mkMerge[
    {
    cudaSupport = true;
    cudaCapabilities = [ "8.9" ];
    cudaForwardCompat = false;
    }
  ];

  hardware.nvidia = {
    open = false;
    nvidiaSettings = true;
    modesetting.enable = true;
    dynamicBoost.enable = true;
    powerManagement.enable = true; # because there is no other GPU to handle desktop
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Add CUDA toolkit to system packages
  environment = lib.mkMerge[
    {
      systemPackages = with pkgs; [
        magma-cuda
        cudatoolkit  # Ensure this is installed system-wide
        cudaPackages.nccl
        cudaPackages.cudnn
        cudaPackages.libnpp
        cudaPackages.cuda_cccl
        cudaPackages.cuda_nvcc
        cudaPackages.cuda_cudart
      ];

      # Add necessary environment variables
      sessionVariables =
      {
        CUDA_PATH = "${pkgs.cudatoolkit}";
        CUDA_CACHE_PATH = "$HOME/.cache/cuda";
        OCL_ICD_VENDORS = "${pkgs.ocl-icd}/etc/OpenCL/vendors/";
        NVIDIA_DRIVER_PATH = "${config.hardware.nvidia.package}";

        # Modify compilation flags
        CFLAGS = "-fPIC";
        CXXFLAGS = "-fPIC";
        FFLAGS = "-fPIC";
        FCFLAGS = "-fPIC";

        # Additional linking flags
        LDFLAGS = "-L${pkgs.cudatoolkit}/lib64 -L/run/opengl-driver/lib -Wl,-rpath,${pkgs.cudatoolkit}/lib64";

        # CUDA-specific flags
        CUDA_CFLAGS = "-I${pkgs.cudatoolkit}/include";
        CUDA_PATH_V12_4 = "${pkgs.cudatoolkit}";       # Adjust version as needed

        # Wayland/KDE specific
        KWIN_DRM_USE_EGL_STREAMS = "1";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";  # Added for better compatibility
        GBM_BACKEND = "nvidia-drm";  # Added for better Wayland support

        PATH = lib.mkBefore [ "${pkgs.cudatoolkit}/bin" ];
        LD_LIBRARY_PATH = lib.mkBefore [
          "${pkgs.cudatoolkit}/lib64"
          "/run/opengl-driver/lib"
          "/run/opengl-driver-32/lib"
        ];
      };
    }
  ];





}