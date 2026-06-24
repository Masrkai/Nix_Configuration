{ pkgs, ... }:

{
     environment.systemPackages = with pkgs; [
    # Compiler
    rustc
    llvmPackages_21.llvm   # match the version rustc uses

    # Development tools
    clippy      # Linter for catching common mistakes
    rustfmt     # Code formatter

    # Language Server Protocol (LSP)
    rust-analyzer

    # Package manager
    cargo
      cargo-edit
      cargo-watch

      # Flame-graphing
      cargo-flamegraph

      # Test-Coverage
      cargo-nextest
      cargo-llvm-cov
  ];

}
