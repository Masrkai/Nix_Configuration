{ config, lib, pkgs, modulesPath, ... }:


{
#  services.logind = {
#   # enable = true;
#   lidSwitch = "ignore";
#  };
services.logind.settings.Login.HandleLidSwitch = "ignore";

 systemd = {
    enableEmergencyMode = true;
      oomd = {
        enable = true;                        # Enable systemd-oomd
        enableRootSlice = true;               # Manage memory pressure for root processes
        enableUserSlices = true;              # Manage memory for user sessions, reducing per-user memory pressure
        enableSystemSlice = true;             # Monitor and manage system services to avoid OOM issues
          settings.OOM = {
            MemoryPressureDurationSec="10s";             # Faster response to memory issues
            DefaultMemoryPressureThresholdPercent=50;    # More aggressive memory protection
          };
      };
      slices = {
          "system.slice" = {
            sliceConfig = {
              MemoryPressureLimit = 95;        # Memory pressure limit to trigger actions
              MemoryPressureDurationSec = "10s"; # How long pressure must persist before action
            };
          };

          "user.slice" = {
            sliceConfig = {
              MemoryPressureLimit = 95;
              MemoryPressureDurationSec = "10s";
            };
          };
      };


    # Main systemd sleep configuration
    sleep.extraConfig = ''
      [Sleep]
      AllowSuspend=yes
      SuspendMode=suspend
      SuspendState=mem
    '';
  };



}