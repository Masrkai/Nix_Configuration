{ pkgs, lib, ... }:

{
  # System-wide packages for C++ development
  environment.systemPackages = with pkgs; [
    # Core compilation tools
    gcc              # Provides g++ and the complete GCC toolchain
    clang            # Alternative compiler (your choice)

    # Essential development libraries - these are the key missing pieces
    glibc.dev        # C standard library headers
    gcc.cc.lib       # Runtime libraries for GCC
    libgcc           # GCC support library

    # Build tools you'll commonly need
    cmake
    ninja
    pkg-config
    binutils         # Includes ld, ar, etc.
  ];

 environment.variables = {
    # Tell CMake to use g++ instead of clang++
    CXX = "${pkgs.gcc}/bin/g++";
    CC = "${pkgs.gcc}/bin/gcc";

    C_INCLUDE_PATH = "${pkgs.glibc.dev}/include";

    CPLUS_INCLUDE_PATH = lib.concatStringsSep ":" [
      "${pkgs.gcc.cc}/include/c++/${pkgs.gcc.cc.version}"
      "${pkgs.gcc.cc}/include/c++/${pkgs.gcc.cc.version}/x86_64-unknown-linux-gnu"
      "${pkgs.glibc.dev}/include"
    ];


    LIBRARY_PATH = lib.makeLibraryPath [
      pkgs.glibc
      pkgs.libcxx
      pkgs.gcc.cc.lib
      pkgs.stdenv.cc.cc.lib
    ];
  };

  # Keep your existing nix-ld setup for runtime compatibility
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      # Runtime libraries that dynamically linked programs might need
      stdenv.cc.cc.lib
      glibc
      libgcc
      zlib
      openssl
      # Add others as needed for your specific programs
    ];
  };


}