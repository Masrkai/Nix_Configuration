# PowerManagement.nix
{ lib, config, pkgs, ... }:

{
  imports = [
    ../ID/ID.nix
    # Auto-import the generated hardware config (will be created after first boot)
    (if builtins.pathExists /etc/nixos/Sec/hardware-detected.nix
     then /etc/nixos/Sec/hardware-detected.nix
     else {})
  ];

    # Enable power-profiles-daemon for ASUS TUF laptops
    services.power-profiles-daemon = {
      enable = config.hardware.isAsusTuf;
    };

    #--> Better scheduling for better CPU cycles & audio performance
    services.system76-scheduler = {
      enable = true;
    };

    services.supergfxd.enable = false;


    services.asusd = lib.mkIf config.hardware.isAsusTuf {
      enable = true;
      enableUserService = true;
    };

    systemd.services.asusd = lib.mkIf config.services.asusd.enable {
      environment.RUST_LOG = "asusd=warn";
    };


    # TLP configuration (disabled when power-profiles-daemon is active)
    services.tlp = {
      enable =  config.hardware.isDellG15 ;

      settings = {
        # AC power settings
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

        # Battery power settings
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

        # Additional power saving
        WIFI_PWR_ON_BAT = "on";
      };
    };
}