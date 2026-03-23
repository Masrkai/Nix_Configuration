{ pkgs, ... }:

{
     environment.systemPackages = with pkgs; [
    # Compiler
    rustc

    # Development tools
    clippy      # Linter for catching common mistakes
    rustfmt     # Code formatter

    # Language Server Protocol (LSP)
    rust-analyzer

    # Package manager
    cargo
      # Flame-graphing
      cargo-flamegraph

      # Test-Coverage
      cargo-nextest
      cargo-llvm-cov
  ];

}