{ lib, ... }:

#*#########################
#* Networking-Configration:
#*#########################
let 

  secrets = import ./secrets.nix;


in{
  # services.avahi.enable = true;
  services.resolved.enable = false;
  networking = lib.mkForce {
      useDHCP = true;
      hostName = "NixOS";                        #* Defining hostname.
      enableIPv6 = false;                        #* Disabling IPV6 to decrease attack surface for good
      nftables.enable = true;                    #* Using the newer standard instead of iptables
      dhcpcd.extraConfig = "nohook resolv.conf"; #* prevent overrides by dhcpcd
      usePredictableInterfaceNames = false ;     #* wlan0 wlan1 instead of gebrish
      nameservers = [
        # "::1"     #> IPv6
        "127.0.0.1" #> IPv4
        ];

      #! Firewall
      firewall = {
      enable = true;
      allowedTCPPorts = [
                          6881 #? Qbittorrent
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
      enable = true;
      dns = "none";  #-> Disable NetworkManager's DNS management
      ensureProfiles = {
        environmentFiles = [ "/etc/nixos/Sec/network-manager.env" ];
        profiles = {
#?//////////////////////////////////////////////////////////////////////////////   Networks
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
              mac-address-randomization = "always";
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
              mac-address-randomization = "always";
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
              mac-address-randomization = "always";  #? or "default" or "never"
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
              mac-address-randomization = "never";  #? or "default" or "never"
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
              mac-address-randomization = "default";  #? or "default" or "never"
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
        "127.0.0.1"
        # "0::1"
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