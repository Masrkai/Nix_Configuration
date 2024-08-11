{

#*#########################
#* Networking-Configration:
#*#########################

  networking.hostName = "NixOS"; # Defining hostname.
  networking.networkmanager.enable = true;
  networking.usePredictableInterfaceNames = false ;

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 443 8888  8384  22000 18081 /*#Syncthing */  ];
  networking.firewall.allowedUDPPorts = [ 443 22000 21027 18081 /*#Syncthing */ ];


  # Configure network proxy if necessary
  #networking.proxy.default = "https://88.198.212.86:3128/";
  #networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

}