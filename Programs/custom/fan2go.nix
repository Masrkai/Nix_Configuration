{ config, pkgs, ... }:

{
  # Define the systemd service
  systemd.services.fan2go = {
    description = "Advanced Fan Control program";

    serviceConfig = {
      LimitNOFILE = 8192;
      Environment = "DISPLAY=:0";
      ExecStart = "${pkgs.fan2go}/bin/fan2go -c /etc/fan2go/fan2go.yaml --no-style";
      Restart = "always";
      RestartSec = "1s";
    };

    # Ensuring the service runs in multi-user mode
    wantedBy = [ "multi-user.target" ];
  };

  # Import the fan2go configuration file
  environment.etc."fan2go/fan2go.yaml" = {
    source = ./fan2go.yaml;
    mode = "0644";
  };

    #hardware.sensor.iio.enable = true;

}