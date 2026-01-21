{pkgs, ... }:

{

  environment.systemPackages = with pkgs; [
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

}