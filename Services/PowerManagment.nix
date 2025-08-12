{ lib, config, pkgs, ... }:

let
  ID = import ./ID.nix { inherit lib; };
in
{



  services.power-profiles-daemon = {
    enable = true;
  };


  services.tlp = {
    enable = true;

    # Optional: override default settings
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      START_CHARGE_THRESH_BAT0 = 75;  # start charging below 75%
      STOP_CHARGE_THRESH_BAT0 = 90;   # stop charging above 90%
    };
  };
}