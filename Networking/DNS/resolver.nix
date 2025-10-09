{ pkgs, lib, ... }:


{

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
      # Note use this command to get the SHA256 of the DNS
      # echo | openssl s_client -connect 1.1.1.1:853 -servername cloudflare-dns.com 2>/dev/null | openssl x509 -pubkey -noout | openssl pkey -pubin -outform der | openssl dgst -sha256 -binary | base64
        {
          address_data = "1.1.1.1";
          tls_auth_name = "cloudflare-dns.com";
          tls_pubkey_pinset = {
            digest = "sha256";
            value = "SPfg6FluPIlUc6a5h313BDCxQYNGX+THTy7ig5X3+VA="; # Same pin for both IPs
          };
        }
        {
          address_data = "1.0.0.1";
          tls_auth_name = "cloudflare-dns.com";
          tls_pubkey_pinset = {
            digest = "sha256";
            value = "SPfg6FluPIlUc6a5h313BDCxQYNGX+THTy7ig5X3+VA="; # Same pin for both IPs
          };
        }

      # Note use this command to get the SHA256 of the DNS
      # echo | openssl s_client -connect 8.8.8.8:853 -servername dns.google.com 2>/dev/null | openssl x509 -pubkey -noout | openssl pkey -pubin -outform der | openssl dgst -sha256 -binary | base64
        {
          address_data = "8.8.8.8";
          tls_auth_name = "dns.google";
          tls_pubkey_pinset = {
            digest = "sha256";
            value = "47DEQpj8HBSa+/TImW+5JCeuQeRkm5NMpJWZG3hSuFU="; # Same pin for both IPs
          };
        }
        {
          address_data = "8.8.4.4";
          tls_auth_name = "dns.google";
          tls_pubkey_pinset = {
            digest = "sha256";
            value = "47DEQpj8HBSa+/TImW+5JCeuQeRkm5NMpJWZG3hSuFU="; # Same pin for both IPs
          };
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


}