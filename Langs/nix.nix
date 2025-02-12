{ lib, pkgs, ... }:

{
  nixpackages = with pkgs; [
    #-> Nix
    nixd
    alejandra

    direnv
    nix-tree
    nix-direnv
    nix-eval-jobs
    nix-output-monitor
  ];

  nix-nixpkgs-extensions = with pkgs.vscode-extensions; [
    mkhl.direnv
    jnoortheen.nix-ide
    arrterian.nix-env-selector
  ];

  nix-marketplace-extensions = with pkgs.vscode-utils.extensionsFromVscodeMarketplace; [

  ];
}