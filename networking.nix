{ lib, ... }:

#*#########################
#* Networking-Configration:
#*#########################
{
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = lib.mkDefault 1;                           #? For Hotspot

    "net.ipv4.tcp_base_mss" = lib.mkDefault 1024;                      #? Set the initial MTU probe size (in bytes)
    "net.ipv4.tcp_mtu_probing" = lib.mkDefault 1;                      #? MTU Probing

    "net.ipv4.tcp_rmem" = "4096 87380 12582912";
    "net.ipv4.tcp_wmem" = "4096 65536 12582912";

    "net.ipv4.tcp_timestamps" = lib.mkDefault 1;                       #? TCP timestamps
    "net.ipv4.tcp_max_tso_segments" =  lib.mkDefault 2;                #? limit on the maximum segment size

    #? Enable BBR congestion control algorithm
    "net.core.default_qdisc" = lib.mkDefault "fq";
    "net.ipv4.tcp_congestion_control" = lib.mkDefault "bbr";
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
                          53         #? DNS
                          587        #? outlook.office365.com Mail server
                          853        #?DNSoverTLS
                          1234       #? NTS Time server
                          6881       #? Qbittorrent
                          16509      #? libvirt
                          8384 22000 #? Syncthing
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
      ensureProfiles = {
        environmentFiles = [ "/etc/nixos/Sec/network-manager.env" ];
        profiles = {
#?//////////////////////////////////////////////////////////////////////////////   Networks
            "Ethernet" = {
                connection = {
                id = "Ethernet";
                type = "ethernet";
                permissions = "";
                interface-name = "eth0";              # Specify the interface name
                autoconnect = true;
                permanent = true;  # This makes the profile persistent
                };
                ethernet = {
                  mac-address-randomization = 2;  #? options:  "never" = 0, "default" = 1, or "always" = 2.
                };
                ipv4 = {
                  method = "auto";         #? Use DHCP for IPv4
                  dns = "127.0.0.1";       #? Local DNS resolver
                  ignore-auto-dns = true;  #? Ignore DNS provided by DHCP
                };
                ipv6 = {
                  method = "disabled";      #? Disable IPv6
                };
            };
            "Ethernet 1" = {
                connection = {
                id = "Ethernet 1";
                type = "ethernet";
                permissions = "";
                interface-name = "eth0";              # Specify the interface name
                autoconnect = false;
                permanent = true;  # This makes the profile persistent
                };
                ethernet = {
                  mac-address-randomization = 2;  #? options:  "never" = 0, "default" = 1, or "always" = 2.
                };
                ipv4 = {
                  method = "manual";
                  address1 = "192.168.2.10/24,192.168.2.1";  # IP/prefix,gateway
                  dns = "127.0.0.1";         # You can add more DNS servers if needed
                  ignore-auto-dns = true;
                };
                ipv6 = {
                  method = "disabled";      #? Disable IPv6
                };
            };
            "USB" = {
                connection = {
                id = "USB";
                type = "ethernet";
                permissions = "";
                interface-name = "eth1";              # Specify the interface name
                autoconnect = true;
                permanent = true;  # This makes the profile persistent
                };
                ethernet = {
                  mac-address-randomization = 2;  #? options:  "never" = 0, "default" = 1, or "always" = 2.
                };
                ipv4 = {
                  method = "auto";         #? Use DHCP for IPv4
                  dns = "127.0.0.1";       #? Local DNS resolver
                  ignore-auto-dns = true;  #? Ignore DNS provided by DHCP
                };
                ipv6 = {
                  method = "disabled";      #? Disable IPv6
                };
            };
#->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
          "Nix_Hotspot" = {
            connection = {
              id = "Nix_Hotspot";
              type = "wifi";
              autoconnect = false;
              permissions = "";
            };
            wifi = {
              mode = "ap";
              ssid = "Nix_Hotspot";
              hidden = true;  # Changed to true for better security
              band = "bg";
              powersave = 2;
            };
            wifi-security = {
              key-mgmt = "wpa-psk";
              psk = "\${AFafAfaf_psk}";
              group = "ccmp";
              pairwise = "ccmp";
              proto = "rsn";
              pmf = 2;
            };
            ipv4 = {
              method = "shared";         # Use shared mode for hotspot
              # dns = "127.0.0.1";         # Use local Stubby instance
              dns-search = "";           # Disable DNS search
              ignore-auto-dns = true;    # Ignore DNS from DHCP
            };
            ipv6.method = "disabled";
          };
#->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
          Repel = {
            connection = {
              id = "Repel";
              type = "wifi";
              permissions = "";
              autoconnect = true;
              autoconnect-priority = 1;  #! Higher means more priority priority
            };
            wifi = {
              ssid = "Repel";
              mode = "infrastructure";
              mac-address-randomization = 2;  #? options:  "never" = 0, "default" = 1, or "always" = 2.
            };
            wifi-security = {
              key-mgmt = "wpa-psk";
              psk = "\${Repel_psk}";
              auth-alg = "open";
            };
            ipv4 = {
                  method = "manual";
                  address1 = "192.168.1.10/24,192.168.1.1";  # IP/prefix,gateway
                  dns = "127.0.0.1";         # You can add more DNS servers if needed
                  ignore-auto-dns = true;
                };
            ipv6 = {
              method = "disabled";
            };
          };
#->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
          AfafAfaf = {
            connection = {
              id = "AfafAfaf";
              type = "wifi";
              permissions = "";
              autoconnect = true;
              autoconnect-priority = 1;  #! Higher means more priority priority
            };
            wifi = {
              ssid = "AfafAfaf";
              mode = "infrastructure";
              mac-address-randomization = 2;  #? options:  "never" = 0, "default" = 1, or "always" = 2.
            };
            wifi-security = {
              key-mgmt = "wpa-psk";
              psk = "\${AFafAfaf_psk}";
              auth-alg = "open";
            };
            ipv4 = {
              method = "auto";
              dns = "127.0.0.1";
              ignore-auto-dns = true;
            };
            ipv6 = {
              method = "disabled";
            };
          };
#->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
          Meemoo = {
            connection = {
              id = "Meemoo";
              type = "wifi";
              permissions = "";
              autoconnect = true;
              autoconnect-priority = 2;  #! Higher means more priority priority
            };
            wifi = {
              ssid = "Meemoo";
              mode = "infrastructure";
              mac-address-randomization = 2;  #? options:  "never" = 0, "default" = 1, or "always" = 2.
            };
            wifi-security = {
              key-mgmt = "wpa-psk";
              psk = "\${Meemoo_psk}";
              auth-alg = "open";
            };
            ipv4 = {
              method = "auto";
              dns = "127.0.0.1";
              ignore-auto-dns = true;
            };
            ipv6 = {
              method = "disabled";
            };
          };
#->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
          ALY2 = {
            connection = {
              id = "ALY2";
              type = "wifi";
              permissions = "";
              autoconnect = true;
              autoconnect-priority = 3;  #! Higher means more priority priority
              };
            wifi = {
              ssid = "ALY2";
              mode = "infrastructure";
              mac-address-randomization = 2;  #? options:  "never" = 0, "default" = 1, or "always" = 2.
              # mac-address = "00:11:22:33:44:55";   # Set your desired MAC address here
            };
            wifi-security = {
              key-mgmt = "wpa-psk";
              psk = "\${ALY2_psk}";
              auth-alg = "open";
            };
            ipv4 = {
              method = "auto";
              dns = "127.0.0.1";
              ignore-auto-dns = true;
            };
            ipv6 = {
              method = "disabled";
            };
          };
#->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
          "Hello!" = {
            connection = {
              id = "Hello!";
              type = "wifi";
              permissions = "";
              autoconnect = true;
              autoconnect-priority = 4;  #! Higher means more priority priority
            };
            wifi = {
              hidden = true;            #! Specify if the network is hidden
              ssid = "Hello!";
              mode = "infrastructure";
              bssid = "46:FB:5A:D1:93:49";
              mac-address-randomization = 0;  #? options:  "never" = 0, "default" = 1, or "always" = 2.
              cloned-mac-address= "\${Hello_device_mac}";
            };
            wifi-security = {
              key-mgmt = "wpa-psk";
              psk = "\${Hello_psk}";
              auth-alg = "open";
            };
            ipv4 = {
              method = "auto";
              dns = "127.0.0.1";
              ignore-auto-dns = true;
            };
            ipv6 = {
              method = "disabled";
            };
          };
#->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
          "Custom" = {
            connection = {
              id = "Custom";
              type = "wifi";
              permissions = "";
              autoconnect = true;
              autoconnect-priority = 4;  #! Higher means more priority priority
            };
            wifi = {
              hidden = true;            #! Specify if the network is hidden
              ssid = "Hello";
              mode = "infrastructure";
              mac-address-randomization = 0;  #? options:  "never" = 0, "default" = 1, or "always" = 2.
              cloned-mac-address= "\${Hello_device_mac}";
            };
            wifi-security = {
              key-mgmt = "wpa-psk";
              psk = "\${Hello_psk}";
              auth-alg = "open";
            };
            ipv4 = {
              method = "auto";
              dns = "127.0.0.1";
              ignore-auto-dns = true;
            };
            ipv6 = {
              method = "disabled";
            };
          };
#->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
          "RN-Meemoo" = {
            connection = {
              id = "RN-Meemoo";
              type = "wifi";
              permissions = "";
              autoconnect = true;
              autoconnect-priority = 4;  #! Higher means more priority priority
            };
            wifi = {
              hidden = true;            #! Specify if the network is hidden
              ssid = "M1";
              mode = "infrastructure";
              bssid = "D8:0D:17:AA:E4:1D";
              mac-address-randomization = "never";  #? or "default" or "never"
              cloned-mac-address= "\${M1_device_mac}";
            };
            wifi-security = {
              key-mgmt = "wpa-psk";
              psk = "\${M1_psk}";
              auth-alg = "open";
            };
            ipv4 = {
              method = "manual";
              address1 = "192.168.1.71/24,192.168.1.1";  # IP/prefix,gateway
              dns = "127.0.0.1";         # You can add more DNS servers if needed
              ignore-auto-dns = true;
            };
            ipv6 = {
              method = "disabled";
            };
          };
#->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
          "Library" = {
            connection = {
              id = "Library";
              type = "wifi";
              permissions = "";
              autoconnect = true;
              autoconnect-priority = 2;  #! Higher means more priority priority
            };
            wifi = {
              hidden = false;            #! Specify if the network is hidden
              ssid = "Study";
              mode = "infrastructure";
              bssid = "A4:B2:39:9C:EC:C0";
              mac-address-randomization = 2;  #? options:  "never" = 0, "default" = 1, or "always" = 2.
            };
            wifi-security = {
              key-mgmt = "wpa-psk";
              psk = "\${Study_psk}";
              auth-alg = "open";
            };
            ipv4 = {
              method = "auto";
              dns = "127.0.0.1";
              ignore-auto-dns = true;
            };
            ipv6 = {
              method = "disabled";
            };
          };
#->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
          "GU-Dorms" = {
            connection = {
              id = "GU-Dorms";
              type = "wifi";
              permissions = "";
              autoconnect = true;
              autoconnect-priority = 2;  #! Higher means more priority priority
            };
            wifi = {
              hidden = false;            #! Specify if the network is hidden
              ssid = "GU-Dorms";
              mode = "infrastructure";
              mac-address-randomization = 2;  #? options:  "never" = 0, "default" = 1, or "always" = 2.
            };
            wifi-security = {
              key-mgmt = "wpa-psk";
              psk = "\${GU_DORMS_PSK}";
              auth-alg = "open";
            };
            ipv4 = {
              method = "auto";
              dns = "127.0.0.1";
              ignore-auto-dns = true;
            };
            ipv6 = {
              method = "disabled";
            };
          };
#->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
          "GU-WiFi" = {
            connection = {
              id = "GU-WiFi";
              type = "wifi";
              permissions = "";
              autoconnect = false;
              autoconnect-priority = 2;  #! Higher means more priority priority
            };
            wifi = {
              hidden = false;            #! Specify if the network is hidden
              ssid = "GU-WiFi";
              mode = "infrastructure";
              mac-address-randomization = 2;  #? options:  "never" = 0, "default" = 1, or "always" = 2.
            };
            wifi-security = {
              key-mgmt = "none";  # Changed from "wpa-psk"
            };
            ipv4 = {
              method = "auto";
              dns = "127.0.0.1";
              ignore-auto-dns = true;
            };
            ipv6 = {
              method = "disabled";
            };
          };
#->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
          # You can add more profiles here following the same structure
        };
      };
    };
  };

  #> DNS-over-TLS
  services.resolved.enable = lib.mkForce false;
  services.stubby = lib.mkForce {
    enable = true;
    settings = {
    listen_addresses = [ "127.0.0.1@53"
                        #  "0.0.0.0@53"
                        #"172.20.0.1@53"       #? Listen on the default NetworkManager shared subnet
                        #"0::1@5353"           #! ::1 cause error, use 0::1 instead
                       ];
    idle_timeout = 15000;
    round_robin_upstreams = 1;
    edns_client_subnet_private = 1;
    tls_query_padding_blocksize = 256;
    dnssec = "GETDNS_EXTENSION_TRUE";
    tls_min_version = "GETDNS_TLS1_3";
    appdata_dir = "/var/cache/stubby";
    resolution_type = "GETDNS_RESOLUTION_STUB";
    dnssec_return_status = "GETDNS_EXTENSION_TRUE";
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
        {
          address_data = "9.9.9.9";
          tls_auth_name = "dns.quad9.net";
        }
        {
          address_data = "149.112.112.112";
          tls_auth_name = "dns.quad9.net";
        }
      ];
    };
  };

  # Define the network check script
  environment.etc."check-internet.sh" = {
    text = ''
      #!/bin/sh
      # Check for internet connectivity by pinging a reliable external host (e.g., Cloudflare's 1.1.1.1)
      if curl -s https://1.1.1.1 > /dev/null; then
        echo "Internet connection is working."
      else
        echo "No internet connection. Restarting stubby..."
        systemctl restart stubby.service
      fi
    '';
    mode = "0700";  # Only the owner (root) can read, write, and execute
    uid = 0;        # Set owner to root (user ID 0)
    gid = 0;        # Set group to root (group ID 0)
  };

  # Create a systemd service that runs the check-internet script periodically
  systemd.services.check-internet = {
    description = "Check for internet connectivity and restart stubby if down";
    serviceConfig = {
      ExecStart = "/etc/check-internet.sh";
    };
    wantedBy = [ "multi-user.target" ];
  };

  # Create a systemd timer to run the check-internet service every 5 minutes
  systemd.timers.check-internet = {
    description = "Run check-internet every 1 minute";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "1min";   # First run 1 minute after boot
      OnUnitActiveSec = "1min";  # Run every 5 minutes
    };
  };

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