#*#########################
#* Networking-Configration:
#*#########################

{
  #   networking.wireless = {
  #   enable = true;  # Enables wireless support via wpa_supplicant.
  #   networks = {
  #     "Hello!" = {
  #       psk = "WHY2HATEme>.>";
  #       hidden = true;
  #     };
  #     "AfafAfaf" = {
  #       psk = "19781978";
  #     };
  #   };
  # };

  services.resolved.enable = false;
  networking = {
    hostName = "NixOS"; #* Defining hostname.
    enableIPv6 = false; #* Disabling IPV6 to decrease attack surface for good
    nftables.enable = true; #* Using the newer standard instead of iptables
    dhcpcd.extraConfig = "nohook resolv.conf"; #* prevent overrides by dhcpcd
    nameservers = [ "::1" "127.0.0.1"];
    usePredictableInterfaceNames = false ; #* wlan0 wlan1 instead of gebrish
    networkmanager = {
      enable = true;
      dns = "none";  #-> Disable NetworkManager's DNS management
    };

    #! Firewall
    firewall = {
      enable = true;
      allowedTCPPorts = [ 443 8888 8384 22000 18081 ];
      allowedUDPPorts = [ 443 22000 21027 18081 ];
      logReversePathDrops = true;

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
      listen_addresses = [ 
        "127.0.0.1"
        "0::1"
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

  # Ensure Stubby starts before network services
  systemd.services.stubby = {
    wantedBy = [ "multi-user.target" ];
    before = [ "network.target" "NetworkManager.service" ];
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