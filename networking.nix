{ lib, ... }:


#*#########################
#* Networking-Configration:
#*#########################
{
  imports = [
    ./NetworkProfiles.nix
  ];

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = lib.mkDefault 0;                           #? For Hotspot

    "net.ipv4.tcp_base_mss" = lib.mkDefault 1024;                      #? Set the initial MTU probe size (in bytes)
    "net.ipv4.tcp_mtu_probing" = lib.mkDefault 1;                      #? MTU Probing

    "net.ipv4.tcp_rmem" = lib.mkForce "4096 1048576 16777216";  # min/default/max
    "net.ipv4.tcp_wmem" = lib.mkForce "4096 1048576 16777216";  # min/default/max

    "net.ipv4.tcp_timestamps" = lib.mkDefault 1;                       #? TCP timestamps
    "net.ipv4.tcp_max_tso_segments" =  lib.mkDefault 2;                #? limit on the maximum segment size

    #? Enable BBR congestion control algorithm
    "net.core.default_qdisc" = lib.mkDefault "fq";
    "net.ipv4.tcp_congestion_control" = lib.mkDefault "bbr";

    #? Memory preserving
    "vm.min_free_kbytes" = lib.mkForce 65536;
  };

  networking = {
      useDHCP = false;
      hostName = "NixOS";                        #* Defining hostname.
      enableIPv6 = false;                        #* Disabling IPV6 to decrease attack surface for good
      nftables.enable = true;                    #* Using the newer standard instead of iptables

      usePredictableInterfaceNames = false ;     #* wlan0 wlan1 instead of gebrish
      dhcpcd.extraConfig = "nohook resolv.conf"; #* prevent overrides by dhcpcd

      wireless.athUserRegulatoryDomain = true;
      resolvconf.extraOptions = [
      "ndots:1"
      "timeout:2"
      "attempts:3"
      "edns0"
      ];
      nameservers = [
        # "::1"     #> IPv6
        "127.0.0.1" #> IPv4
        ];

      #! Firewall
      firewall = {
      enable = true;
      allowedTCPPorts = [
                          # 53         #? DNS
                          # 587        #? outlook.office365.com Mail server
                          # 853        #?DNSoverTLS
                          1234         #? NTS Time server
                          # 6881       #? Qbittorrent
                          # 16509      #? libvirt
                          # 8384 22000 #? Syncthing
                          443 8888 18081
                        ];
      allowedUDPPorts = [
                          6881  #? Qbittorrent
                          18081
                          21027 #? Syncthing
                        ];
      #--> Ranges
      allowedTCPPortRanges = [
                            { from = 1714; to = 1764; }  #? KDEconnect
                             ];
      allowedUDPPortRanges = [
                            { from = 1714; to = 1764; }  #? KDEconnect
                             ];
      logRefusedPackets = true;
      logReversePathDrops = true;
      logRefusedConnections = true;
      };

      networkmanager = lib.mkDefault {
      dns = "none";  #-> Disable NetworkManager's DNS management
      enable = true;
      logLevel = "INFO";
      ethernet.macAddress = "random";  #? Enable random MAC during Ethernet_Connection

      wifi.powersave = true;
      wifi.scanRandMacAddress = true;  #? Enable random MAC during scanning

      settings = {
        global = {
        };
        wifi= {
          #! Enable random MAC address for scanning (prevents exposure during scans)
          "wifi.scan-rand-mac-address" = "2";
        };
        connection = {
          "connection.llmnr" = 2;  # Disable LLMNR
          "connection.mdns" = 2;   # Disable mDNS
        };
      };
    };
  };

  #> SSH
  services.openssh = {
  enable = true;
  ports = [ 22 ];
    settings = {
      PasswordAuthentication = true;
      AllowUsers = null; # Allows all users by default. Can be [ "user1" "user2" ]
      UseDns = true;
      X11Forwarding = false;
      PermitRootLogin = "prohibit-password"; # "yes", "without-password", "prohibit-password", "forced-commands-only", "no"
    };
  };

  #> DNS-over-TLS
  services.resolved.enable = lib.mkForce false;
  services.stubby = lib.mkForce {
    enable = true;
    settings = {
    listen_addresses = [ "127.0.0.1@53"
                        #"0.0.0.0@53"
                        #"172.20.0.1@53"       #? Listen on the default NetworkManager shared subnet
                        #"0::1@5353"           #! ::1 cause error, use 0::1 instead
                       ];

    idle_timeout = 300000;
    round_robin_upstreams = 1;
    edns_client_subnet_private = 1;

    tls_min_version = "GETDNS_TLS1_3";
    tls_query_padding_blocksize = 256;

    dnssec = "GETDNS_EXTENSION_TRUE";
    dnssec_return_status = "GETDNS_EXTENSION_TRUE";

    appdata_dir = "/var/cache/stubby";
    resolution_type = "GETDNS_RESOLUTION_STUB";
    dns_transport_list = [ "GETDNS_TRANSPORT_TLS" ];
    tls_authentication = "GETDNS_AUTHENTICATION_REQUIRED";
    tls_ciphersuites = "TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_128_GCM_SHA256";
    # prefetch = "true";
    # hide_identity = "true";   # Hides the identity of the resolver
    # hide_version = "true";    # Hides the version of the resolver
      upstream_recursive_servers = [
        {
          address_data = "1.1.1.1";
          tls_auth_name = "cloudflare-dns.com";
        }
        {
          address_data = "1.0.0.1";
          tls_auth_name = "cloudflare-dns.com";
        }
        # {
        #   address_data = "9.9.9.9";
        #   tls_auth_name = "dns.quad9.net";
        # }
        # {
        #   address_data = "149.112.112.112";
        #   tls_auth_name = "dns.quad9.net";
        # }
      ];
    };
  };

  # # Define the network check script
  # environment.etc."check-internet.sh" = {
  #   text = ''
  #     #!/bin/sh
  #     # Check for internet connectivity by pinging a reliable external host (e.g., Cloudflare's 1.1.1.1)
  #     if curl -s https://1.1.1.1 > /dev/null; then
  #       echo "Internet connection is working."
  #     else
  #       echo "No internet connection. Restarting stubby..."
  #       systemctl restart stubby.service
  #     fi
  #   '';
  #   mode = "0700";  # Only the owner (root) can read, write, and execute
  #   uid = 0;        # Set owner to root (user ID 0)
  #   gid = 0;        # Set group to root (group ID 0)
  # };

  # # Create a systemd service that runs the check-internet script periodically
  # systemd.services.check-internet = {
  #   description = "Check for internet connectivity and restart stubby if down";
  #   serviceConfig = {
  #     ExecStart = "/etc/check-internet.sh";
  #   };
  #   wantedBy = [ "multi-user.target" ];
  # };

  # # Create a systemd timer to run the check-internet service every 5 minutes
  # systemd.timers.check-internet = {
  #   description = "Run check-internet every 1 minute";
  #   wantedBy = [ "timers.target" ];
  #   timerConfig = {
  #     OnBootSec = "1min";   # First run 1 minute after boot
  #     OnUnitActiveSec = "1min";  # Run every 5 minutes
  #   };
  # };

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