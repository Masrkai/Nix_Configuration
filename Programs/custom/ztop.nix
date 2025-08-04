{ config, pkgs, ... }:

let
  Bashpkgs = import ./Bash/ztop.nix { inherit pkgs; };

  Pythonpkgs = import ./Python/ztop.nix { inherit pkgs; };
in
{

  environment.systemPackages = with pkgs; [
    Bashpkgs.backup
    Bashpkgs.extract
    Bashpkgs.setupcpp

    Pythonpkgs.ctj
    Pythonpkgs.MD-PDF
    Pythonpkgs.mac-formatter
  ];
}