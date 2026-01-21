{ lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    #* Build Systems
    cmake
    ninja
    gnumake
    pkg-config

    #* Static Analysis
    cppcheck

    #* UI Toolkits
    gtk3
    gtk4
    kdePackages.qtbase # Qt runtime
    kdePackages.qttools # Qt development tools (qmake, designer)

    #* IDE Support (Consider these optional based on your IDE)
    qtcreator

    #* Libraries
    eigen
    nlohmann_json

    #* GCC Toolchain (with higher priority to avoid collisions)
    (lib.hiPrio gcc14)

    #* LLVM/Clang Toolchain
    #
    # llvmPackages_20.clangWithLibcAndBasicRtAndLibcxx
    llvmPackages_20.clang
    llvmPackages_20.clang-tools
    llvmPackages.bintools

    #* Tests
    gtest
    coreutils-prefixed

  ];

}