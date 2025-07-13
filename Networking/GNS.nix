{ config, pkgs, lib, ... }:

{

   services.gns3-server = {
    enable = true;
    package = pkgs.gns3-server;

      auth = {
        enable = true;
        user = "masrkai";
        passwordFile = "/var/lib/secrets/gns3_password";
      };

      ssl = {
        enable = false;
        certFile = "/var/lib/gns3/ssl/cert.pem";
        keyFile = "/var/lib/gns3/ssl/key.pem";
      };

      settings = {
          Server ={
            port = 3080;
            host = "127.0.0.1";

            images_path = "~/GNS3/images";
            symbols_path = "~/GNS3/symbols";
            configs_path = "~/GNS3/configs";
            projects_path = "~/GNS3/projects";
            appliances_path = "~/GNS3/appliances";
          };
        };


   #! Supports:

      #? DHCP and ping
      vpcs = {
       enable = true;
       package = pkgs.vpcs;
      };

      #? cisco images emulation
      dynamips = {
       enable = true;
       package = pkgs.dynamips;
      };

      ubridge = {
       enable = true;
       package = pkgs.ubridge;
      };
   };

  environment.systemPackages = with pkgs; [ gns3-gui];

}