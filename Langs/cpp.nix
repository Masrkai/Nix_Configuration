{ lib, pkgs, ... }:

{
  cpppackages = with pkgs; [
    # ? Builders
    cmake ninja gnumake cppcheck pkg-config

    # ? UIs
    gtk3 gtk4 qtcreator kdePackages.qtbase kdePackages.qttools

    # ? Libraries
    eigen
    nlohmann_json
    (hiPrio boost185)

    # ! Compilers + Extras

    # Add these C/C++ development essentials
    (lowPrio gdb)
    (hiPrio gcc_multi)
    glibc glibc.dev gcc-unwrapped.lib
    clang_multi clang-tools llvmPackages.libcxx
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