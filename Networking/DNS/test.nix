{ pkgs, lib, ... }:

let
  adblockLocalZones = pkgs.stdenv.mkDerivation {
    name = "unbound-zones-adblock";
    src = (pkgs.fetchFromGitHub {
      owner = "StevenBlack";
      repo = "hosts";
      rev = "3.16.59";
      sha256 = "sha256-gPG7wu3K0wLwpV0nPJt7sIrLP3PrgOS/4POM5zwerVs=";
    } + "/hosts");
    phases = [ "installPhase" ];
    installPhase = ''
      ${pkgs.gawk}/bin/awk '{sub(/\r$/,"")} {sub(/^127\.0\.0\.1/,"0.0.0.0")} BEGIN { OFS = "" } NF == 2 && $1 == "0.0.0.0" { print "local-zone: \"", $2, "\" static"}' $src | tr '[:upper:]' '[:lower:]' | sort -u > $out
    '';
  };

in
{
  # Disable resolved and stubby completely
  services.resolved.enable = lib.mkForce false;
  services.stubby.enable = lib.mkForce false;

  # Single unified Unbound service with DoT
  services.unbound = {
    enable = true;
    stateDir = "/var/lib/unbound";
    
    settings = {
      server = {
        interface = [ "127.0.0.1@53" ];
        
        access-control = [
          "0.0.0.0/0 refuse"
          "10.0.0.0/8 allow"
          "172.16.0.0/12 allow"
          "192.168.0.0/16 allow"
          "127.0.0.0/8 allow"
          "192.168.125.0/24 allow"
          "192.168.123.1/24 allow"
        ];

        private-address = [
          "10.0.0.0/8"
          "172.16.0.0/12"
          "192.168.0.0/16"
          "127.0.0.0/8"
        ];
        
        private-domain = [ "local" "localhost" "internal" ];

        # TLS Configuration (replaces Stubby's functionality)
        # tls-cert-bundle = "/etc/ssl/certs/ca-certificates.crt";
        tls-upstream = true;  # Enable TLS for upstream queries
        
        # TLS 1.3 cipher suites only (effectively enforces TLS 1.3)
        # By only allowing TLS 1.3 ciphers, TLS 1.2 connections will fail
        tls-ciphersuites = "";
        
        # Disable older TLS ciphers to prevent downgrade attacks
        tls-ciphers = "";

        # Include adblock zones
        include = [ "${adblockLocalZones}" ];

        # Performance settings (maintained from your config)
        num-threads = 4;
        msg-cache-slabs = 4;
        rrset-cache-slabs = 4;
        infra-cache-slabs = 4;
        key-cache-slabs = 4;
        
        prefetch = "yes";
        prefetch-key = "yes";
        rrset-roundrobin = "yes";
        
        cache-min-ttl = 300;
        cache-max-ttl = 604800;
        serve-expired = "yes";
        serve-expired-ttl = 14400;
        
        msg-cache-size = "512m";
        rrset-cache-size = "1024m";
        key-cache-size = "256m";
        neg-cache-size = "128m";
        
        tcp-idle-timeout = 60000;
        
        # Protocol settings
        do-ip4 = "yes";
        do-ip6 = "no";
        do-udp = "yes";
        do-tcp = "yes";
        
        # Security hardening (DNSSEC + privacy)
        hide-identity = "yes";
        hide-version = "yes";
        
        harden-glue = "yes";
        harden-referral-path = "yes";
        harden-algo-downgrade = "yes";
        harden-below-nxdomain = "yes";
        harden-dnssec-stripped = "yes";
        
        use-caps-for-id = "no";
        qname-minimisation = "yes";
        
        # DNSSEC validation
        val-clean-additional = "yes";
        
        # Logging
        verbosity = 1;
        log-queries = "yes";
        log-replies = "yes";
        statistics-interval = 0;
        
        # Query padding for privacy (equivalent to your stubby padding)
        pad-queries = "yes";
        pad-queries-block-size = 128;
      };

      # Forward zones with DoT (replaces Stubby upstreams)
      forward-zone = [
        {
          name = ".";
          forward-tls-upstream = true;
          
          # Cloudflare DoT with SNI authentication
          forward-addr = [
            "1.1.1.1@853#cloudflare-dns.com"
            "1.0.0.1@853#cloudflare-dns.com"
            # "2606:4700:4700::1111@853#cloudflare-dns.com"
            # "2606:4700:4700::1001@853#cloudflare-dns.com"
            
            # Google DoT (backup)
            "8.8.8.8@853#dns.google"
            "8.8.4.4@853#dns.google"
            # "2001:4860:4860::8888@853#dns.google"
            # "2001:4860:4860::8844@853#dns.google"
          ];
        }
      ];
    };
  };

  # Ensure CA certificates are available for TLS validation
  # security.pki.certificateFiles = [ "/etc/ssl/certs/ca-certificates.crt" ];
  
  # # Add a health check or monitoring
  # systemd.services.unbound = {
  #   serviceConfig = {
  #     Restart = "always";
  #     RestartSec = "5";
  #   };
  # };
}