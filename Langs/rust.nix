{ pkgs, ... }:

{
  rustpackages = with pkgs; [
    # Compiler
    rustc

    # Package manager
    cargo

    # Development tools
    clippy      # Linter for catching common mistakes
    rustfmt     # Code formatter

    # Language Server Protocol (LSP)
    rust-analyzer

    # # Toolchain manager
    # rustup      # Manages Rust versions and targets
  ];

  rust-nixpkgs-extensions = with pkgs.vscode-extensions; [
    fill-labs.dependi
    rust-lang.rust-analyzer
    tamasfe.even-better-toml
  ];

  rust-marketplace-extensions = with pkgs.vscode-utils.extensionsFromVscodeMarketplace; [

  ];
}