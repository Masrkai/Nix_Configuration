{ lib, pkgs, ... }:

with lib;
mkMerge [
  # Kernel and boot security configurations
  {
    networking.networkmanager.ensureProfiles = {
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
            "virbr0" = {
                connection = {
                id = "virbr0";
                type = "bridge";
                permissions = "";
                interface-name = "virbr0";              # Specify the interface name
                autoconnect = true;
                permanent = true;  # This makes the profile persistent
                };
                ethernet = {
                  mac-address-randomization = 2;  #? options:  "never" = 0, "default" = 1, or "always" = 2.
                };
                ipv4 = {
                  method = "manual";         #? Use DHCP for IPv4
                  dns = "127.0.0.1";         #? Local DNS resolver
                  ignore-auto-dns = true;    #? Ignore DNS provided by DHCP
                  address1 = "192.168.122.1/24,0.0.0.0";  #? IP/prefix,gateway
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
              autoconnect-priority = 0;  #! Higher means more priority priority
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

  }

]