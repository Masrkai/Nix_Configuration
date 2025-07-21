{ lib, pkgs, ... }:

{
  cpppackages = with pkgs; [
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
    # (hiPrio boost185) # Consider specific boost modules instead of the whole library

    #* GCC Toolchain (with higher priority to avoid collisions)
    (hiPrio gcc14)

    #* LLVM/Clang Toolchain
    llvmPackages_20.clangWithLibcAndBasicRtAndLibcxx
    llvmPackages_20.clang-tools
    llvmPackages.bintools

  ];

  cpp-nixpkgs-extensions = with pkgs.vscode-extensions; [
    twxs.cmake
    vadimcn.vscode-lldb
    llvm-vs-code-extensions.vscode-clangd
  ];

  cpp-marketplace-extensions = with pkgs.vscode-utils.extensionsFromVscodeMarketplace; [
    {
      # https://marketplace.visualstudio.com/items?itemName=cheshirekow.cmake-format
      name = "cmake-format";
      publisher = "cheshirekow";
      version = "0.6.11";
      hash = "sha256-NdU8J0rkrH5dFcLs8p4n/j2VpSP/X7eSz2j4CMDiYJM=";
    }
    {
      #https://open-vsx.org/extension/KylinIdeTeam/cmake-intellisence
      name = "cmake-intellisence";
      publisher = "KylinIdeTeam";
      version = "0.3.3";
      hash = "sha256-wCT5I1qobNmXaO7otoe6Tdg2p7a3CgUk5pc5BJW3r20=";
    }
  ];
}