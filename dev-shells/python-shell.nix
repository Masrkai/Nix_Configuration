{ nixpkgsConfig ? {}
, enableCuda ? false
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
    stdenv.cc.cc.lib
    libxkbcommon
    fontconfig
    wayland          # Add this
    qt6.qtwayland   # Add this
    glib
    zlib
    xorg.libX11      # Add this
    xorg.libXext     # Add this too for good measure
    freetype        # Add this
    zstd            # Add this
    dbus            # Add this



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
    pythonPackages.virtualenv
    pythonPackages.setuptools
    pythonPackages.wheel
    pkgs.openssl
    pkgs.pkg-config
    pkgs.libxkbcommon
    pkgs.fontconfig  # Add this line
    pkgs.wayland     # Add this
    pkgs.qt6.qtwayland  # Add this
    setupEnvScript
    pkgs.xorg.libX11     # Add this
    pkgs.xorg.libXext    # Add this too
    pkgs.freetype    # Add this
    pkgs.zstd        # Add this
    pkgs.dbus        # Add this

  ] ++ dev-tools
    ++ (lib.optionals enableCuda cuda-common-pkgs)
    ++ (lib.optionals enableAudio audio-pkgs)
    ++ (lib.optionals enableMonitoring monitoring-pkgs);


    # source ${setupEnvScript}/bin/setup-env
  shellHook =''
    # Inline the script contents or source it
    export LD_LIBRARY_PATH="${libraryPath}:$LD_LIBRARY_PATH"
    source ${setupEnvScript}/bin/setup-env
  '';
}
