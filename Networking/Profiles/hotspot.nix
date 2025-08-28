{ lib, ... }:

lib.mkMerge [
    {
        networking.networkmanager.ensureProfiles.profiles = {
              "Nix_Hotspot" = {
                connection = {
                  type = "wifi";
                  id   = "Nix_Hotspot";
                  uuid = "902355cd-5047-3733-809e-d279d2fccb28";
                  permissions = "";
                  autoconnect = false;
                };
                wifi = {
                  mode = "ap";
                  band = "bg";
                  ssid = "Nix_Hotspot";
                  hidden = false;  # Changed to true for better security
                  powersave = 0;
                };
                wifi-security = {
                  key-mgmt = "wpa-psk";
                  psk = "\${Nix_Hotspot_psk}";
                  group = "ccmp";
                  pairwise = "ccmp";
                  proto = "rsn";
                  pmf = 2;
                };
                ipv4 = {
                  # dns-data = "192.168.125.1";
                  dns-search = "";           # Disable DNS search
                  ignore-auto-dns = true;    # Ignore DNS from DHCP

                  method = "shared";         # Use shared mode for hotspot
                  addresses = "192.168.125.1/24";
                  gateway = "192.168.125.1";
                };
                ipv6.method = "disabled";
              };

        };

    }

]