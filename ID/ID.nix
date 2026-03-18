# ID.nix - Simple hardware detection with global config
{ lib, config, pkgs, ... }:

let
  # Global configuration - change this path if needed
  hardwareConfigFile = "/etc/nixos/Sec/hardware-detected.nix";
  
  # Path to the detection script
  detectScript = ./detect-hardware.sh;

in {
  options = {
    hardware = {
      isAsusTuf = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether this is an ASUS TUF Gaming laptop";
      };

      isIdeaPad5 = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether this is a LENOVO IdeaPad 5 laptop";
      };

      isThinkPad = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether this is a ThinkPad laptop";
      };

      isDellG15 = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether this is a Dell laptop";
      };
    };
  };

  config = {
    system.activationScripts.detectHardware = {
      text = ''
        ${pkgs.bash}/bin/bash ${detectScript} ${hardwareConfigFile}
      '';
      deps = [ ];
    };
  };
}