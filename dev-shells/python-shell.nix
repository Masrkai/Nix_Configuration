{ nixpkgsConfig ? {}
, enableCuda ? true
, enableAudio ? false
, enableMonitoring ? false
, pythonVersion ? 312
}:

let
  nixpkgs = import <nixpkgs> {
    config = {
      allowUnfree = true;
      cudaSupport = enableCuda;
    } // nixpkgsConfig.config or {};
    overlays = nixpkgsConfig.overlays or [];
  };

  inherit (nixpkgs) pkgs lib;

  PyVersion = pythonVersion;
  pythonSP = pkgs."python${toString PyVersion}";
  pythonPackages = pkgs."python${toString PyVersion}Packages";

  libraryPath = with pkgs; lib.makeLibraryPath ([
    zstd
    zlib
    glib
    glibc_multi

    dbus
    wayland
    freetype
    fontconfig
    xorg.libX11
    xorg.libXext
    libxkbcommon
    qt6.qtwayland
    stdenv.cc.cc.lib
  ] ++ lib.optionals enableCuda [
    cudatoolkit
    cudaPackages.cudnn
  ]);

  dev-tools = with pkgs; [
    git gcc gdb lldb glibc cmake ninja ccache gnumake valgrind pkg-config
  ];

  cuda-common-pkgs = with pkgs.cudaPackages; lib.optionals enableCuda [
    nccl cudnn cuda_nvcc cuda_cudart cudatoolkit
  ];

  monitoring-pkgs = with pkgs; [
    htop
    iotop
    nethogs
    nvtopPackages.full
  ];

  audio-pkgs = with pkgs; [
    jack2
    pipewire
    alsa-lib
    portaudio
    wireplumber
    libpulseaudio
  ];

  setupEnvScript = pkgs.writeTextFile {
    name = "setup-env";
    destination = "/bin/setup-env";
    text = ''
      #!/usr/bin/env bash

      # Variables exported from Nix
      export PyVersion="${toString PyVersion}"
      export enableCuda="${if enableCuda then "1" else "0"}"
      export CUDA_PATH="${pkgs.cudatoolkit}"
      export LIBRARY_PATH="${libraryPath}"

      # Source the provided setup-env.sh script
      source ${./setup-env.sh}
    '';
    executable = true;
    checkPhase = ''
      ${pkgs.bash}/bin/bash -n $out/bin/setup-env
    '';
  };

in pkgs.mkShell {
  buildInputs = [
    pythonSP
    pythonPackages.pip
    pythonPackages.wheel
    pythonPackages.virtualenv
    pythonPackages.setuptools

    pkgs.dbus
    pkgs.zstd
    pkgs.wayland
    pkgs.openssl
    pkgs.freetype
    setupEnvScript
    pkgs.fontconfig
    pkgs.pkg-config
    pkgs.xorg.libX11
    pkgs.xorg.libXext
    pkgs.libxkbcommon
    pkgs.qt6.qtwayland
  ] ++ dev-tools
    ++ (lib.optionals enableCuda cuda-common-pkgs)
    ++ (lib.optionals enableAudio audio-pkgs)
    ++ (lib.optionals enableMonitoring monitoring-pkgs);

  shellHook = ''
    # Add OpenGL driver path and additional library paths
    export LD_LIBRARY_PATH="/run/opengl-driver/lib:${libraryPath}:$LD_LIBRARY_PATH"
    export TRITON_LIBCUDA_PATH="/run/opengl-driver/lib"
    export PTXAS_PATH=$(which ptxas)
    
    # Fix Triton ptxas issue on NixOS:
    # Remove the bundled ptxas (which is not runnable on NixOS) and symlink the system one.
    TRITON_PTXAS="/home/masrkai/Virtual/Python/.python-312/lib/python3.12/site-packages/triton/backends/nvidia/bin/ptxas"
    if [ -e "$TRITON_PTXAS" ]; then
      rm -f "$TRITON_PTXAS"
      ln -s "$(which ptxas)" "$TRITON_PTXAS"
      echo "Fixed Triton ptxas: linked system ptxas at $(which ptxas)"
    fi

    # Source the environment setup script.
    source ${setupEnvScript}/bin/setup-env
  '';
}
