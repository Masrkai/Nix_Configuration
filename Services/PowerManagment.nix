# PowerManagement.nix
{ lib, config, pkgs, ... }:

{
  imports = [
    ../ID.nix
    # Auto-import the generated hardware config (will be created after first boot)
    (if builtins.pathExists /etc/nixos/Sec/hardware-detected.nix
     then /etc/nixos/Sec/hardware-detected.nix
     else {})
  ];

  config = {
    # Enable power-profiles-daemon for ASUS TUF laptops
    services.power-profiles-daemon = {
      enable = config.hardware.isAsusTuf;
    };

    # TLP configuration (disabled when power-profiles-daemon is active)
    services.tlp = {
      enable = !config.hardware.isAsusTuf;

      settings = lib.mkIf (!config.hardware.isAsusTuf) {
        # AC power settings
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

        # Battery power settings
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

        # Battery charge thresholds
        START_CHARGE_THRESH_BAT0 = 75;
        STOP_CHARGE_THRESH_BAT0 = 90;

        # Additional power saving
        WIFI_PWR_ON_BAT = "on";
        SOUND_POWER_SAVE_ON_BAT = 1;
      };
    };

    # # Additional hardware-specific settings
    # boot.kernelParams = lib.mkIf config.hardware.isAsusTuf [ "acpi_backlight=native" ];

    # # ThinkPad specific settings
    # services.thinkfan.enable = lib.mkIf config.hardware.isThinkPad (lib.mkDefault true);

    # # Debug info
    # environment.etc."hardware-status.txt".text = ''
    #   Hardware Detection Status:
    #   Product Name: ${config.hardware.productName}
    #   Is ASUS TUF: ${lib.boolToString config.hardware.isAsusTuf}
    #   Is ThinkPad: ${lib.boolToString config.hardware.isThinkPad}

    #   Services Status:
    #   Power Profiles Daemon: ${lib.boolToString config.services.power-profiles-daemon.enable}
    #   TLP: ${lib.boolToString config.services.tlp.enable}
    #   SuperGFXD: ${lib.boolToString (config.services.supergfxd.enable or false)}
    #   ThinkFan: ${lib.boolToString (config.services.thinkfan.enable or false)}
    # '';
  };
}