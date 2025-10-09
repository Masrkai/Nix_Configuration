# PowerManagement.nix
{ lib, config, pkgs, ... }:

let
  secrets = import ../Sec/secrets.nix;

  # Hardware-specific git configs
  gitConfigs = {
    asus = {
      name = "Masrkai";
      email = secrets.Masrkai_GitHub_Mail;
    };
    dell = {
      name = "maryam-othmann5";
      email = secrets.Maryam_GitHub_Mail;
    };
  };

  # Select appropriate config
  userConfig =
    if config.hardware.isAsusTuf then gitConfigs.asus
    else if config.hardware.isDellG15 then gitConfigs.dell
    else throw "Undetected hardware: No matching hardware configuration found to configure git";

in

{
  imports = [
    ../ID/ID.nix
  ];

  #--> Git // LFS
  programs.git = {
    enable = true;
    lfs = {
      enable = true;
      package = pkgs.git-lfs;
    };


    config = {
      user = userConfig;
      init.defaultBranch = "main";
    };

  };
}