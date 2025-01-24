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
    glib
    zlib
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

    echo "Environment setup complete! 🚀"
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
    setupEnvScript
  ] ++ dev-tools
    ++ (lib.optionals enableCuda cuda-common-pkgs)
    ++ (lib.optionals enableAudio audio-pkgs)
    ++ (lib.optionals enableMonitoring monitoring-pkgs);


  shellHook =''
    # Inline the script contents or source it
    source ${setupEnvScript}/bin/setup-env
  '';
}