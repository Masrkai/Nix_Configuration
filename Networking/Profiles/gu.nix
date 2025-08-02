{ lib, ... }:

lib.mkMerge [
    {
        networking.networkmanager.ensureProfiles.profiles = {
          "Library" = {
            connection = {
              id = "Library";
              type = "wifi";
              permissions = "";
              autoconnect = true;
              autoconnect-priority = 2;
            };
            wifi = {
              hidden = false;
              ssid = "Study";
              mode = "infrastructure";
              bssid = "A4:B2:39:9C:EC:C0";
              mac-address-randomization = 2;
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
              permissions = "";
              autoconnect = true;
              autoconnect-priority = 2;
            };
            wifi = {
              hidden = false;
              ssid = "GU-Dorms";
              mode = "infrastructure";
              mac-address-randomization = 2;
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

          "GU-WiFi" = {
            connection = {
              id = "GU-WiFi";
              type = "wifi";
              permissions = "";
              autoconnect = false;
              autoconnect-priority = 2;
            };
            wifi = {
              hidden = false;
              ssid = "GU-WiFi";
              mode = "infrastructure";
              mac-address-randomization = 2;
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

          "Gu_EMP" = {
            connection = {
              type = "wifi";
              id   = "Gu_EMP";
              uuid = "a92cb91e-7a05-3f23-8092-9bc829ddc87d";
              permissions = "";
              autoconnect = true;
              autoconnect-priority = 4;
            };
            wifi = {
              hidden = false;
              ssid = "Gu_EMP";
              mode = "infrastructure";
              mac-address-randomization = 0;
              cloned-mac-address= "\${Gu_EMP_mac}";
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