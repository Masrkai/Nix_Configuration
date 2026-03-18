{ pkgs, lib, ... }:


{
    # Make sure time synchronization is properly handled
    services.timesyncd.enable = false;  # Disable systemd-timesyncd to avoid conflicts
    time.hardwareClockInLocalTime = false;  # Use UTC for hardware clock
    services.chrony = {
    enable = true;
    enableNTS = true;
    enableMemoryLocking = true;
    servers = [
      "time.cloudflare.com"  # NTS port
      ];
    };

}