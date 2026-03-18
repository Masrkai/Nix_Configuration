# PowerManagement.nix
{ lib, config, pkgs, ... }:

let
  secrets = import ../Sec/secrets.nix;

  # Hardware-specific git configs
  gitConfigs = {
    isAsusTuf = {
      name = "Masrkai";
      email = secrets.Masrkai_GitHub_Mail;
    };
    isDellG15 = {
      name = "maryam-othmann5";
      email = secrets.Maryam_GitHub_Mail;
    };
  };

  # Select appropriate config
  userConfig =
    if config.hardware.isAsusTuf then gitConfigs.isAsusTuf
    else if config.hardware.isDellG15 then gitConfigs.isDellG15
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