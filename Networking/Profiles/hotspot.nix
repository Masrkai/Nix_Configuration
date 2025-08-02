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
                  hidden = true;  # Changed to true for better security
                  powersave = 0;
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
                  dns-search = "";           # Disable DNS search
                  method = "shared";         # Use shared mode for hotspot
                  ignore-auto-dns = true;    # Ignore DNS from DHCP
                  address1 = "192.168.125.1/24,192.168.125.1";
                };
                ipv6.method = "disabled";
              };

        };

    }

]