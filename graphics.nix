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
  #> Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];

  services.xserver.screenSection = ''
    option "TearFree" "true"
    option "VariableRefresh" "true"
  '';

  # Add this to your configuration.nix or home.nix
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # Add libraries that might be needed
    libGL
    libGLU
  ];

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
    extraPackages = with pkgs; [

      #! OpenCL
      # ocl-icd
      opencl-clhpp
      opencl-headers
      khronos-ocl-icd-loader

      libglvnd
      vaapiVdpau
      egl-wayland
      libvdpau-va-gl

      #! Vulkan
      vulkan-tools
      vulkan-loader
      nvidia-vaapi-driver

      # linuxPackages.nvidia_x11.out # includes OpenCL libraries
    ];
  };

  nix.settings = lib.mkMerge [
    {
      substituters = [
        "https://cuda-maintainers.cachix.org"
      ];
      trusted-public-keys = [
        "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      ];
    }
  ];

  nixpkgs = {

    config = {
      cudaSupport = true;
      cudaCapabilities = [
        "8.9"    # RTX 40 series
        # "8.6"    # RTX 30 series
        # "7.5"    # RTX 20 series
      ];
      cudaForwardCompat = false;
    };
  };

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
  environment = lib.mkMerge [{
    systemPackages = let
      # Group packages by functionality for better maintenance
      graphicsDiagnostics = with pkgs; [
        clinfo     # OpenCL information
        glxinfo    # GLX diagnostics
        vulkan-tools  # Vulkan utilities
        libva-utils  # VA-API diagnostics
      ];

      performanceTools = with pkgs; [
        mangohud  # Performance monitoring
      ];

      videoAcceleration = with pkgs; [
        libva-vdpau-driver
        nvidia-vaapi-driver
        vaapiVdpau
      ];

      cudaEcosystem = with pkgs; [
        magma
        magma-cuda
        cudatoolkit
        cudaPackages.nccl
        cudaPackages.cudnn
        cudaPackages.libnpp
        cudaPackages.cuda_cccl
        cudaPackages.cuda_nvcc
        cudaPackages.cuda_cudart
      ];
    in
      graphicsDiagnostics ++
      performanceTools ++
      videoAcceleration ++
      cudaEcosystem;

    sessionVariables = let
      # Security-critical paths
      cudaPath = "${pkgs.cudatoolkit}";
      nvidiaPath = "${config.hardware.nvidia.package}";
      openglPath = "/run/opengl-driver";

      

      # Secure base library paths - ordered by priority
      baseLibPaths = [
        "${cudaPath}/lib64"
        "${openglPath}/lib"
        "${openglPath}-32/lib"
        "${pkgs.libglvnd}/lib"
        "${pkgs.nvidia-vaapi-driver}/lib"
        "${pkgs.vaapiVdpau}/lib"
      ];

      # Additional security-vetted libraries
      extraLibs = lib.makeLibraryPath [
        pkgs.khronos-ocl-icd-loader
        pkgs.libvdpau
      ];

      # Path security utilities
      sanitizePath = path: lib.removePrefix ":" (lib.removeSuffix ":" path);

      # Secure path concatenation with validation
      safeConcatPaths = paths:
        sanitizePath (lib.concatStringsSep ":" (lib.filter (x: x != null && x != "") paths));

      # Final secured library path
      fullLibPath = safeConcatPaths (baseLibPaths ++ lib.splitString ":" extraLibs);

      # Compiler security flags
      securityFlags = "-fPIC -fstack-protector-strong -D_FORTIFY_SOURCE=2";
    in {
      # CUDA Configuration - Hardened
      CUDA_PATH = cudaPath;
      CUDA_CACHE_PATH = "$HOME/.cache/cuda";
      CUDA_CFLAGS = "-I${cudaPath}/include ${securityFlags}";
      NVCC_FLAGS = "-O3 ${securityFlags}";
      LIBVA_DRIVER_NAME = "nvidia";
      VDPAU_DRIVER = "nvidia";
      NVD_BACKEND = "direct";

      # OpenCL Security Configuration
      OCL_ICD_VENDORS = "${pkgs.ocl-icd}/etc/OpenCL/vendors/";

      # Driver Security Configuration
      NVIDIA_DRIVER_PATH = nvidiaPath;

      # Hardened Compiler Flags
      CFLAGS = lib.mkAfter securityFlags;
      FFLAGS = lib.mkAfter securityFlags;
      FCFLAGS = lib.mkAfter securityFlags;
      CXXFLAGS = lib.mkAfter securityFlags;

      # Secure Linker Configuration
      LDFLAGS = lib.mkAfter (lib.concatStringsSep " " [
        "-L${cudaPath}/lib64"
        "-L${openglPath}/lib"
        "-Wl,-rpath,${cudaPath}/lib64"
        "-Wl,--as-needed"
        "-Wl,-z,now"  # Immediate binding
        "-Wl,-z,relro"  # Full RELRO
      ]);

      # Wayland/KDE Security Hardening
      KWIN_DRM_USE_EGL_STREAMS = "1";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      GBM_BACKEND = "nvidia-drm";
      EGL_PLATFORM = "wayland";
      WLR_NO_HARDWARE_CURSORS = "1";

      # Secure Path Configuration
      PATH = lib.mkBefore [
        "${cudaPath}/bin"
        "${pkgs.nvidia-vaapi-driver}/bin"
      ];

      # Library Path with Secure Composition
      LD_LIBRARY_PATH = lib.mkMerge [
        (lib.mkForce (lib.makeLibraryPath [
          # Your critical paths in order of priority
          pkgs.cudatoolkit
          "/run/opengl-driver"
          "/run/opengl-driver-32"
          pkgs.libglvnd
          pkgs.nvidia-vaapi-driver
          pkgs.vaapiVdpau
          pkgs.khronos-ocl-icd-loader
          pkgs.libvdpau
        ]))
        # Allow other modules to append their paths
        "\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}"
      ];
    };
  }];

}