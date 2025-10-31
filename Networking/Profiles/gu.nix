{ lib, ... }:

lib.mkMerge [
    {
        networking.networkmanager.ensureProfiles.profiles = {
          "Library" = {
            connection = {
              id = "Library";
              type = "wifi";
              uuid = "0ea68fe5-6bab-4f05-926a-dd90666a75da";
              permissions = "";
              autoconnect = true;
              autoconnect-priority = 0;
            };
            wifi = {
              hidden = false;
              ssid = "Study";
              mode = "infrastructure";
              bssid = "A4:B2:39:9C:EC:C0";
              cloned-mac-address = "random";
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

          "GU-Dorms" = {
            connection = {
              id = "GU-Dorms";
              type = "wifi";
              uuid = "f43ba556-93d8-4b63-b08b-16bc6d2c2f20";
              permissions = "";
              autoconnect = true;
              autoconnect-priority = 1;
            };
            wifi = {
              hidden = false;
              ssid = "GU-Dorms";
              mode = "infrastructure";
              cloned-mac-address = "random";
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

          "GU-Wifi" = {
            connection = {
              id = "GU-Wifi";
              type = "wifi";
              uuid = "916ee28c-e288-47ba-b06a-b672d739c14a";
              permissions = "";
              autoconnect = false;
              autoconnect-priority = 2;
            };
            wifi = {
              hidden = false;
              ssid = "GU-WiFi";
              mode = "infrastructure";
              cloned-mac-address = "random";
            };
            ipv4 = {
              method = "auto";
              dns = "127.0.0.1";
              dhcp-timeout = 90;           # Increase timeout
              ignore-auto-dns = true;
              dhcp-send-hostname = false;  # Some Cisco networks reject hostname
            };
            ipv6 = {
              method = "disabled";
            };
          };

          "Gu_EMP" = {
            connection = {
              type = "wifi";
              id   = "Gu_EMP";
              uuid = "a92cb91e-7a05-3f23-8092-9bc829ddc87d";
              permissions = "";
              autoconnect = false;
              autoconnect-priority = 3;
            };
            wifi = {
              hidden = false;
              ssid = "Gu_EMP";
              mode = "infrastructure";
              #mac-address-randomization = 0;
              # cloned-mac-address= "\${Gu_EMP_mac}";
            };
            wifi-security = {
              key-mgmt = "wpa-psk";
              psk = "\${Gu_EMP_pass}";
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

        };

    }

]