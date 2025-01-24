{ config, pkgs, lib, ... }:

let
  libraries = with pkgs; [
    cudatoolkit
    libglvnd
    nvidia-vaapi-driver
    vaapiVdpau
    khronos-ocl-icd-loader
    libvdpau
  ];
in

{

  boot = lib.mkMerge [
    {
      initrd.kernelModules = [
      "nvidia"
      "nvidia_drm"
      "nvidia_uvm"
      "nvidia_modeset"
      ];

      kernelModules = [
      "nvidia"
      "nvidia_drm"
      "nvidia_uvm"
      "nvidia_modeset"
      ];

      kernelParams = [
      "pci=realloc=on"

      "nvidia-drm.modeset=1"
      "NVreg_PreserveVideoMemoryAllocations=1"
      "nvidia.NVreg_TemporaryFilePath=/var/tmp"

      # Additional parameters for better performance and stability
      "nvidia.NVreg_UsePageAttributeTable=1"
      # "nvidia.NVreg_EnablePCIeGen3=1"
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
    enable32Bit = false;
    extraPackages = with pkgs; [
      # mesa

      #! OpenCL
      # ocl-icd
      opencl-clhpp
      opencl-headers
      khronos-ocl-icd-loader

      libglvnd
      egl-wayland

      #! Vulkan
      vulkan-tools
      vulkan-loader
      nvidia-vaapi-driver
    ];
  };

  #> Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];

  nixpkgs.config = lib.mkMerge[
    {
    cudaSupport = true;
    cudaCapabilities = [
      "8.9"    #? RTX 40 series
      "8.6"    #? RTX 30 series
      "7.5"    #? RTX 20 series
    ];
    cudaForwardCompat = false;
    }
  ];

  hardware.nvidia = {
    open = false;
    nvidiaSettings = true;
    modesetting.enable = true;
    dynamicBoost.enable = true;
    powerManagement.enable = true; # because there is no other GPU to handle desktop
    forceFullCompositionPipeline = true;  # Better screen tearing prevention
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Add CUDA toolkit to system packages
  environment = lib.mkMerge[
    {

      systemPackages = with pkgs; [
        clinfo
        glxinfo

        mangohud
        vulkan-tools
        libva-vdpau-driver

        magma-cuda
        cudatoolkit  # Ensure this is installed system-wide
        cudaPackages.nccl
        cudaPackages.cudnn
        cudaPackages.libnpp
        # cudaPackages.tensorrt  # Added for AI/ML acceleration
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
        LDFLAGS = "-L${pkgs.cudatoolkit}/lib64 -L/run/opengl-driver/lib -Wl,-rpath,${pkgs.cudatoolkit}/lib64 -Wl,--as-needed";

        # CUDA-specific flags
        CUDA_CFLAGS = "-I${pkgs.cudatoolkit}/include";
        NVCC_FLAGS = "-O3";  # Optimization for CUDA compilation


        # Wayland/KDE specific
        KWIN_DRM_USE_EGL_STREAMS = "1";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";  # Added for better compatibility
        GBM_BACKEND = "nvidia-drm";  # Added for better Wayland support
        EGL_PLATFORM = "wayland";  # Added for explicit EGL platform selection
        WLR_NO_HARDWARE_CURSORS = "1";  # Added for better cursor handling
        LIBVA_DRIVER_NAME = "nvidia";  # Added for VA-API support

        PATH = lib.mkBefore [
          "${pkgs.cudatoolkit}/bin"
          "${pkgs.nvidia-vaapi-driver}/bin"
        ];

        LD_LIBRARY_PATH = lib.mkBefore ([
          "${pkgs.cudatoolkit}/lib64"
          "/run/opengl-driver/lib"
          "/run/opengl-driver-32/lib"
          "${pkgs.libglvnd}/lib"
          "${pkgs.nvidia-vaapi-driver}/lib"
          "${pkgs.vaapiVdpau}/lib"
        ] ++ (lib.splitString ":" (lib.makeLibraryPath [
          pkgs.khronos-ocl-icd-loader
          pkgs.libvdpau
        ])));

        #  LD_LIBRARY_PATH = lib.mkAfter"${pkgs.lib.makeLibraryPath libraries}:$LD_LIBRARY_PATH";


      };


    }
  ];
}