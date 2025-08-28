{ pkgs, lib, ... }:


#*#########################
#* Networking-Configration:
#*#########################
{
  imports = [
    ./NetworkProfiles.nix
    # ./Wireless_Regulation.nix
    ./Network_Kernel_Parameters.nix
  ];

  networking = {
      useDHCP = false;
      hostName = "NixOS";                        #* Defining hostname.
      enableIPv6 = false;                        #* Disabling IPV6 to decrease attack surface for good
      nftables.enable = true;                    #* Using the newer standard instead of iptables

      usePredictableInterfaceNames = false ;     #* wlan0 wlan1 instead of gebrish
      dhcpcd.extraConfig = "nohook resolv.conf"; #* prevent overrides by dhcpcd

      resolvconf.extraOptions = [
      "ndots:1"
      "timeout:2"
      "attempts:3"
      "edns0"
      ];
      nameservers = [
        # "::1"     #> IPv6
        "127.0.0.1" #> IPv4
        ];

      #! Firewall
      firewall = {
      enable = true;
      allowedTCPPorts = [
                          # 53         #? DNS shouldn't be opened unless it's a DNS server for a router
                          853          #? For stubby DNS over TLS

                          # 587        #? outlook.office365.com Mail server
                          # 853        #?DNSoverTLS
                          1234         #? NTS Time server
                          # 6881       #? Qbittorrent
                          # 16509      #? libvirt
                          # 5353
                          443        #? OpenVPN
                          8384 22000 #? Syncthing
                          8888 18081
                        ];

      allowedUDPPorts = [
                          1337  #? OpenVPN
                          6881  #? Qbittorrent
                          18081
                          21027 #? Syncthing
                          21116 #? RustDesk
                        ];
      #--> Ranges
      allowedTCPPortRanges = [
                              { from = 1714; to = 1764; }    #? KDEconnect
                              { from = 21114; to = 21119; }  #? RustDesk
                             ];
      allowedUDPPortRanges = [
                            { from = 1714; to = 1764; }  #? KDEconnect
                             ];
      logRefusedPackets = true;
      logReversePathDrops = true;
      logRefusedConnections = true;
      };

      networkmanager = lib.mkDefault {
      dns = "none";  #-> Disable NetworkManager's DNS management
      enable = true;
      logLevel = "INFO";
      ensureProfiles.environmentFiles = [ "/etc/nixos/Sec/network-manager.env" ];

      ethernet.macAddress = "random";  #? Enable random MAC during Ethernet_Connection

      wifi.powersave = true;
      wifi.scanRandMacAddress = true;  #? Enable random MAC during scanning

      plugins = with pkgs; [
        networkmanager-openvpn
      ];

      settings = {
        global = {
        };
        wifi= {
          #! Enable random MAC address for scanning (prevents exposure during scans)
          "wifi.scan-rand-mac-address" = "2";
        };
        connection = {
          "connection.llmnr" = 2;  # Disable LLMNR
          "connection.mdns" = 2;   # Disable mDNS
        };
      };
    };
  };


  #> OpenVPN
  programs.openvpn3 = {
    enable = true;
    package = pkgs.openvpn3;

    # Configure logging
    log-service.settings = {
      log_level = 7;  # Info level
      journald = true;
    };

    # Configure DNS integration
    netcfg.settings = {
      systemd_resolved = false;
    };
  };

  environment.systemPackages = with pkgs; [
     easyrsa
     openssl
     ];

  #> SSH
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      PasswordAuthentication = true;
      AllowUsers = null;
      UseDns = true;
      X11Forwarding = false;
      PermitRootLogin = "prohibit-password";
    };

    # Add these lines to support legacy ssh-rsa keys
    hostKeys = [
      {
        path = "/etc/ssh/ssh_host_rsa_key";
        type = "rsa";
        bits = 4096;
      }
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };

  #> DNS-over-TLS
  services.resolved.enable = lib.mkForce false;
  services.stubby = lib.mkForce {
    enable = true;
    settings = {
    listen_addresses = [
                         "127.0.0.1@853"

                         #"0.0.0.0@53"
                         #"172.20.0.1@53"       #? Listen on the default NetworkManager shared subnet
                         #"0::1@853"           #! ::1 cause error, use 0::1 instead
                       ];

      # Optimize connection handling
      idle_timeout = 10000;        # Reduced from 300000 to free resources faster
      round_robin_upstreams = 1;   # Enable upstream rotation for load balancing
      edns_client_subnet_private = 1;

      # Enhanced TLS security settings
      tls_min_version = "GETDNS_TLS1_3";
      tls_query_padding_blocksize = 128;  # Reduced from 256 for better performance while maintaining security

      # DNSSEC configuration
      dnssec = "GETDNS_EXTENSION_TRUE";
      dnssec_return_status = "GETDNS_EXTENSION_TRUE";

      # Core settings
      appdata_dir = "/var/cache/stubby";
      resolution_type = "GETDNS_RESOLUTION_STUB";
      dns_transport_list = [ "GETDNS_TRANSPORT_TLS" ];
      tls_authentication = "GETDNS_AUTHENTICATION_REQUIRED";

      # Modern cipher suite selection optimized for performance
      tls_ciphersuites = "TLS_AES_128_GCM_SHA256:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_256_GCM_SHA384";

      # Enable performance optimizations
      # prefetch = true;             # Enable prefetching for faster responses
      timeout = 2000;                # 2 second timeout (lower than default)

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
          address_data = "8.8.8.8";
          tls_auth_name = "dns.google";
        }
        {
          address_data = "8.8.4.4";
          tls_auth_name = "dns.google";
        }

        # {
        #   address_data = "9.9.9.9";
        #   tls_auth_name = "dns.quad9.net";
        # }
        # {
        #   address_data = "149.112.112.112";
        #   tls_auth_name = "dns.quad9.net";
        # }
      ];
    };
  };

  #> DNS Caching using Unbound
    services.unbound = {
      enable = true;
      stateDir = "/var/lib/unbound";
      settings = {
        server = {
          interface = [
            # "0.0.0.0"
            "127.0.0.1" # Listen on localhost
            # "192.168.125.1"  # Listen on hotspot interface
          ];

          # interface-automatic = "yes";

          access-control = [
            "0.0.0.0/0 refuse"     # Refuse all other networks by default

            "10.0.0.0/8 allow"     # Another private network range
            "192.0.0.0/8 allow"    # Private network range
            "172.16.0.0/12 allow"  # Another private network range
            "192.168.0.0/16 allow" # Common home/local network range

            "127.0.0.0/8 allow"    # Localhost
            "192.168.125.0/24 allow"  # Allow hotspot clients
          ];


          # Performance and caching optimization settings
          num-threads = 4;
          msg-cache-slabs = 4;
          rrset-cache-slabs = 4;
          infra-cache-slabs = 4;
          key-cache-slabs = 4;

          # Extended caching configuration
          prefetch = "yes";
          prefetch-key = "yes";
          rrset-roundrobin = "yes";

          # Significantly extended cache times
          cache-min-ttl = 300;        # Minimum 5 minutes (extended from 60 seconds)
          cache-max-ttl = 604800;     # 7 days maximum cache (extended from 24 hours)
          serve-expired = "yes";      # Serve expired records while refreshing
          serve-expired-ttl = 14400;  # Serve expired records for up to 4 hours (extended from 1 hour)

          # Increased cache sizes
          msg-cache-size = "512m";    # Increased from 128m
          rrset-cache-size = "1024m"; # Increased from 256m
          key-cache-size = "256m";    # Increased from 128m
          neg-cache-size = "128m";    # Increased from 32m for longer negative caching

          # Fault tolerance and connection settings
          tcp-idle-timeout = 60000;   # Increased from 30000 to keep connections alive longer

          # Protocol and security settings (maintained)
          do-ip4 = "yes";
          do-ip6 = "no";
          do-udp = "yes";
          do-tcp = "yes";

          qname-minimisation = "yes";
          hide-identity = "yes";
          hide-version = "yes";
          use-caps-for-id = "yes";
          harden-glue = "yes";
          harden-dnssec-stripped = "yes";
          harden-referral-path = "yes";

          # Minimal logging for performance
          verbosity = 1;
          log-queries = "no";
          log-replies = "no";
        };

        forward-zone = [
          {
            name = ".";
            forward-addr = "127.0.0.1@853";  # Match Stubby's port
            forward-first = "yes";
          }
        ];
      };
    };

    services.hostapd = {
      enable = false;
      package = pkgs.hostapd;
    };

    # Make sure time synchronization is properly handled
    services.timesyncd.enable = false;  # Disable systemd-timesyncd to avoid conflicts
    time.hardwareClockInLocalTime = false;  # Use UTC for hardware clock

    services.chrony = {
    enable = true;
    enableNTS = true;
    enableMemoryLocking = true;
    servers = [
      "time.cloudflare.com"  # NTS port
      ];
    };

}