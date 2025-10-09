{pkgs, ... }:

{
  nixpackages = with pkgs; [
    #-> Nix
    nixd
    alejandra

    direnv
    nix-tree
    nix-init
    nix-direnv
    nix-eval-jobs
    nix-output-monitor
    nixpkgs-review gh
  ];

  nix-nixpkgs-extensions = with pkgs.vscode-extensions; [
    mkhl.direnv
    jnoortheen.nix-ide
    arrterian.nix-env-selector
    # jeff-hykin.better-nix-syntax
  ];

  nix-marketplace-extensions = with pkgs.vscode-utils.extensionsFromVscodeMarketplace; [

  ];
}