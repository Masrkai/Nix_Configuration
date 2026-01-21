{ pkgs, ... }:

{
     environment.systemPackages = with pkgs; [
    # Compiler
    rustc

    # Package manager
    cargo

    # Development tools
    clippy      # Linter for catching common mistakes
    rustfmt     # Code formatter

    # Language Server Protocol (LSP)
    rust-analyzer

    # Flame-graphing
     cargo-flamegraph

    # # Toolchain manager
    # rustup      # Manages Rust versions and targets
  ];

}