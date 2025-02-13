{ pkgs, ... }:

{
  rustpackages = with pkgs; [
    rustc
    cargo
    clippy
    rustfmt
    rust-analyzer
  ];

  rust-nixpkgs-extensions = with pkgs.vscode-extensions; [
    rust-lang.rust-analyzer
  ];

  rust-marketplace-extensions = with pkgs.vscode-utils.extensionsFromVscodeMarketplace; [

  ];
}