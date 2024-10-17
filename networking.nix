{ lib, ... }:

#*#########################
#* Networking-Configration:
#*#########################
{
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;      #? For Hotspot

    "net.ipv4.tcp_mtu_probing" = 1;                      #? MTU Probing
    "net.ipv4.tcp_base_mss" = lib.mkDefault 1024;     #? Set the initial MTU probe size (in bytes)

    "net.ipv4.tcp_timestamps" = lib.mkDefault 1;         #? TCP timestamps
    "net.ipv4.tcp_max_tso_segments" =  lib.mkDefault 2;  #? limit on the maximum segment size

    #? Enable BBR congestion control algorithm
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
  };

  # services.avahi.enable = true;
  services.resolved.enable = false;
  networking = lib.mkForce {
      useDHCP = true;
      hostName = "NixOS";                        #* Defining hostname.
      enableIPv6 = false;                        #* Disabling IPV6 to decrease attack surface for good
      nftables.enable = true;                    #* Using the newer standard instead of iptables

      usePredictableInterfaceNames = false ;     #* wlan0 wlan1 instead of gebrish
      dhcpcd.extraConfig = "nohook resolv.conf"; #* prevent overrides by dhcpcd

      wireless.athUserRegulatoryDomain = true;
      nameservers = [
        # "::1"     #> IPv6
        "127.0.0.1" #> IPv4
        ];

      # #! Nat for hotspot
      # nat = {
      #   enable = true;
      #   externalInterface = "eth0";  # Adjust this to your main internet-connected interface
      #   internalInterfaces = [ "wlan0" "wlan1" ];
      # };

      #! Firewall
      firewall = {
      enable = true;
      allowedTCPPorts = [
                          587 #? outlook.office365.com Mail server
                          6881 #? Qbittorrent
                          16509 #? libvirt
                          8384 22000 #? Syncthing
                          443 8888 18081 ];
      allowedUDPPorts = [
                          6881 #? Qbittorrent
                          21027 #? Syncthing
                          443 18081 ];
      #--> Ranges
      allowedTCPPortRanges = [
                            { from = 1714; to = 1764; }  #? KDEconnect
                             ];
      allowedUDPPortRanges = [
                            { from = 1714; to = 1764; }  #? KDEconnect
                             ];
      logReversePathDrops = true;
      };

      networkmanager = {
      dns = "none";  #-> Disable NetworkManager's DNS management
      enable = true;
      ethernet.macAddress = "random";  #? Enable random MAC during Ethernet_Connection
      wifi.scanRandMacAddress = true;  #? Enable random MAC during scanning
      settings = {
        global = {
          #! Enable random MAC address for scanning (prevents exposure during scans)
          "wifi.scan-rand-mac-address" = true;
        };
      };
      ensureProfiles = {
        environmentFiles = [ "/etc/nixos/Sec/network-manager.env" ];
        profiles = {
#?//////////////////////////////////////////////////////////////////////////////   Networks
            "WiredConnection" = {
                connection = {
                id = "WiredConnection";
                type = "ethernet";
                permissions = "";
                interface-name = "eth0";              # Specify the interface name
                autoconnect = true;
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
                  method = "ignore";       #? Disable IPv6
                };
            };
#->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
          "Nix_Hotspot" = {
            connection = {
              id = "Nix_Hotspot";
              type = "wifi";
              interface-name = "wlan0";
            };
            wifi = {
              mode = "ap";
              ssid = "Nix_Hotspot";
            };
            wifi-security = {
              key-mgmt = "wpa-psk";
              psk = "\${AFafAfaf_psk}";  # This will be replaced by the value from the environment file
            };
            ipv4 = {
              method = "shared";
            };
            ipv6.method = "ignore";
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
              hidden = true;            #! Specify if the network is hidden
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

          # You can add more profiles here following the same structure
        };
      };
    };
  };

  #> DNS-over-TLS
  services.stubby = lib.mkForce {
    enable = true;
    settings = {

      # ::1 cause error, use 0::1 instead
        listen_addresses = [
        "127.0.0.1@53"
        #"0::1@53"
        ];

      # https://github.com/getdnsapi/stubby/blob/develop/stubby.yml.example
      resolution_type = "GETDNS_RESOLUTION_STUB";
      dns_transport_list = [ "GETDNS_TRANSPORT_TLS" ];
      tls_authentication = "GETDNS_AUTHENTICATION_REQUIRED";
      tls_query_padding_blocksize = 128;
      idle_timeout = 10000;
      round_robin_upstreams = 1;
      tls_min_version = "GETDNS_TLS1_3";
      dnssec = "GETDNS_EXTENSION_TRUE";
      dnssec_return_status = "GETDNS_EXTENSION_TRUE";
      appdata_dir = "/var/cache/stubby";
      # prefetch = "true";
      # # hide-identity = "true";
      # # hide-version = "true";
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
  environment.etc."check-internet.sh".text = ''
    #!/bin/sh
    # Check for internet connectivity by pinging a reliable external host (e.g., Cloudflare's 1.1.1.1)
    if ping -c 3 1.1.1.1 > /dev/null; then
      echo "Internet connection is working."
    else
      echo "No internet connection. Restarting stubby..."
      systemctl restart stubby.service
    fi
  '';
  environment.etc."check-internet.sh".mode = "0755";  # Add execute permission

  # Create a systemd service that runs the check-internet script periodically
  systemd.services.check-internet = {
    description = "Check for internet connectivity and restart stubby if down";
    serviceConfig = {
      ExecStart = "/etc/check-internet.sh";
    };
    wantedBy = [ "multi-user.target" ];
  };

  # Create a systemd timer to run the service every 5 minutes
  systemd.timers.check-internet = {
    description = "Run check-internet every 5 minutes";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "1min";   # First run 1 minute after boot
      OnUnitActiveSec = "5min";  # Run every 5 minutes
    };
  };

  # #! Enable DHCP server for the hotspot
  # services.kea.dhcp4 = {
  #   enable = true;
  #   settings = {
  #     interfaces-config = {
  #       interfaces = [ "wlan0" "wlan1" ];
  #       service-sockets-require-all = false;
  #       service-sockets-retry-wait-time = 5000;
  #     };
  #     lease-database = {
  #       type = "memfile";
  #       name = "/var/lib/kea/dhcp4.leases";
  #     };
  #     valid-lifetime = 4000;
  #     renew-timer = 1000;
  #     rebind-timer = 2000;
  #     subnet4 = [{
  #       id = 1;  # Add this line
  #       subnet = "10.42.0.0/24";
  #       pools = [{ pool = "10.42.0.2 - 10.42.0.254"; }];
  #       option-data = [
  #         { name = "routers"; data = "10.42.0.1"; }
  #         { name = "domain-name-servers"; data = "127.0.0.1"; }
  #         { name = "subnet-mask"; data = "255.255.255.0"; }
  #       ];
  #     }];
  #   };
  # };

  # Enable Chrony NTS service
  services.chrony = lib.mkForce {
    enable = true;
    enableNTS = true;
    servers = [ "time.cloudflare.com" ];
  };

  # WebRTC leak prevention for Chromium-based browsers
  environment.etc."chromium/policies/managed/policies.json".text = ''
    {
      "WebRtcIPHandlingPolicy": "disable_non_proxied_udp",
      "WebRtcUDPPortRange": "10000-10010",
      "WebRtcLocalIpsAllowedUrls": [""],
      "WebRtcAllowLegacyTLSProtocols": false
    }
  '';

  # WebRTC leak prevention for Firefox
  environment.etc."firefox/policies/policies.json".text = ''
    {
      "policies": {
        "DisableWebRTC": true,
        "Preferences": {
          "media.peerconnection.enabled": false,
          "media.peerconnection.ice.default_address_only": true,
          "media.peerconnection.ice.no_host": true,
          "media.peerconnection.ice.proxy_only": true
        }
      }
    }
  '';


  # Ensure DNS settings persist across reboots
  environment.etc."resolv.conf".text = ''
    nameserver 127.0.0.1
    options edns0 trust-ad
  '';

  # Prevent other services from modifying resolv.conf
  environment.etc."resolv.conf".mode = "0444";  # Read-only

}