#*#########################
#* Networking-Configration:
#*#########################

{
  #   networking.wireless = {
  #   enable = true;  # Enables wireless support via wpa_supplicant.
  #   networks = {
  #     "YourSSID" = {
  #       psk = "YourPassword";
  #     };
  #   };
  # };

  services.resolved = {
    enable = true;
    domains = [ "~." ]; # use as default interface for all requests
    # let Avahi handle mDNS publication
    extraConfig = ''
      MulticastDNS=resolve
    '';
    llmnr = "true";
  };

  networking = {

    hostName = "NixOS"; # Defining hostname.
    nameservers = [ "::1" "127.0.0.1"];

    networkmanager.enable = true;
    usePredictableInterfaceNames = false ;

    #! Firewall
    firewall = {
      enable = true;
      allowedTCPPorts = [ 443 8888  8384  22000 18081 /*#Syncthing */  ];
      allowedUDPPorts = [ 443 22000 21027 18081 /*#Syncthing */ ];

    #? Proxy // IF i ever had one to use
    # proxy = {
    #   default = "https://88.198.212.86:3128/";
    #   noProxy = "127.0.0.1,localhost,internal.domain";
    #  };

    };

  };

  #> DNS-over-TLS
  services.stubby = {
    enable = true;
    settings = {

      # ::1 cause error, use 0::1 instead
      listen_addresses = [ "127.0.0.1" "0::1" ];

      # https://github.com/getdnsapi/stubby/blob/develop/stubby.yml.example
      resolution_type = "GETDNS_RESOLUTION_STUB";
      dns_transport_list = [ "GETDNS_TRANSPORT_TLS" ];
      tls_authentication = "GETDNS_AUTHENTICATION_REQUIRED";
      tls_query_padding_blocksize = 128;
      idle_timeout = 10000;
      round_robin_upstreams = 1;
      tls_min_version = "GETDNS_TLS1_3";
      dnssec = "GETDNS_EXTENSION_TRUE";
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
          address_data = "2606:4700:4700::1111";
          tls_auth_name = "cloudflare-dns.com";
        }
        {
          address_data = "2606:4700:4700::1001";
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
        {
          address_data = "2620:fe::fe";
          tls_auth_name = "dns.quad9.net";
        }
        {
          address_data = "2620:fe::9";
          tls_auth_name = "dns.quad9.net";
        }
      ];
    };
  };

}