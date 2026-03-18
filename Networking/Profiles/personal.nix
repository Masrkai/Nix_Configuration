{ lib, ... }:

lib.mkMerge [
    {
        networking.networkmanager.ensureProfiles.profiles = {
              "Repel" = {
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
                  cloned-mac-address = "random";  #? options:  "never" = 0, "default" = 1, or "always" = 2.
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

              "AfafAfaf" = {
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
                  cloned-mac-address = "random";  #? options:  "never" = 0, "default" = 1, or "always" = 2.
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

              "Meemoo" = {
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
                  cloned-mac-address = "random";  #? options:  "never" = 0, "default" = 1, or "always" = 2.
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

              "ALY2" = {
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
                  cloned-mac-address = "random";  #? options:  "never" = 0, "default" = 1, or "always" = 2.
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

              "Hello!" = {
                connection = {
                  id = "Hello!";
                  type = "wifi";
                  permissions = "";
                  autoconnect = true;
                  autoconnect-priority = 10;  #! Higher means more priority priority
                };
                wifi = {
                  hidden = true;            #! Specify if the network is hidden
                  ssid = "Hello!";
                  mode = "infrastructure";
                  bssid = "46:FB:5A:D1:93:49";
                  #mac-address-randomization = 0;  #? options:  "never" = 0, "default" = 1, or "always" = 2.
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


              "RN-Meemoo" = {
                connection = {
                  id = "RN-Meemoo";
                  type = "wifi";
                  permissions = "";
                  autoconnect = true;
                  autoconnect-priority = 9;  #! Higher means more priority priority
                };
                wifi = {
                  hidden = true;            #! Specify if the network is hidden
                  ssid = "M1";
                  mode = "infrastructure";
                  bssid = "D8:0D:17:AA:E4:1D";
                  #mac-address-randomization = "never";  #? or "default" or "never"
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
        };

    }

]