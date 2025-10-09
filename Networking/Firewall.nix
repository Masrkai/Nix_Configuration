{ pkgs, lib, ... }:

{

  #> Firewall AND WHY SOMETHING IS OPEN
  networking = {
      firewall = {
      enable = true;
      allowedTCPPorts = [
                          # 53         #? DNS shouldn't be opened unless it's a DNS server for a router
                          853          #? For stubby DNS over TLS

                          # 587        #? outlook.office365.com Mail server
                          # 853        #?DNSoverTLS
                          1234         #? NTS Time server
                          # 6881       #? Qbittorrent
                          # 16509      #? libvirt
                          # 5353
                          443          #? OpenVPN
                          8384 22000   #? Syncthing
                          8888 18081
                        ];

      allowedUDPPorts = [

                          67 68 #? DHCP
                          1337  #? OpenVPN
                          6881  #? Qbittorrent
                          18081
                          21027 #? Syncthing
                          21116 #? RustDesk
                        ];
      #--> Ranges
      allowedTCPPortRanges = [
                              { from = 1714; to = 1764; }    #? KDEconnect
                              { from = 21114; to = 21119; }  #? RustDesk
                             ];
      allowedUDPPortRanges = [
                            { from = 1714; to = 1764; }  #? KDEconnect
                             ];
      logRefusedPackets = true;
      logReversePathDrops = true;
      logRefusedConnections = true;
      };
  };

    # Enable Fail2ban
    services.fail2ban.enable = true;

}