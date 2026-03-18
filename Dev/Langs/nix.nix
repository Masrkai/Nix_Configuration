{pkgs, config, ... }:

let

  unstable = import <unstable> {
    # config.allowUnfree = true;
    config = config.nixpkgs.config;
    overlays = [];
    };


in{

  environment.systemPackages = with pkgs; [
    nixd
    alejandra

    direnv
    nix-tree
    nix-init
    unstable.nixoscope
    nix-direnv
    nix-eval-jobs
    nix-output-monitor
    nixpkgs-review gh
  ];

}