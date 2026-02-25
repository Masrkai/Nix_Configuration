{ pkgs, lib, ... }:

let
  StateDirectory = "dnscrypt-proxy";

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
  services.resolved.enable = lib.mkForce false;
  services.stubby.enable = lib.mkForce false;

  services.dnscrypt-proxy = {
    enable = true;
    settings = {
      listen_addresses = [ "127.0.0.1:5300" ];

      sources.public-resolvers = {
        urls = [
          "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
          "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
        ];
        minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
        cache_file = "/var/lib/${StateDirectory}/public-resolvers.md";
      };

      server_names = [
        "cloudflare"
        "cloudflare-security"
        "google"
        "quad9-doh-ip4-port443-filter-ecs-pri"
      ];

      require_dnssec = true;
      require_nolog = true;
      require_nofilter = false;

      ipv6_servers = false;
      block_ipv6 = true;

      keepalive = 30;

      fallback_resolvers = [ "9.9.9.9:53" "8.8.8.8:53" ];
      ignore_system_dns = true;

      log_level = 2;
    };
  };

  systemd.services.dnscrypt-proxy2.serviceConfig.StateDirectory = StateDirectory;

  services.unbound = {
    enable = true;
    stateDir = "/var/lib/unbound";

    settings = {
      server = {
        interface = [ "127.0.0.1@53" ];
        ip-freebind = "no";

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

        include = [ "${adblockLocalZones}" ];

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

        do-ip4 = "yes";
        do-ip6 = "no";
        do-udp = "yes";
        do-tcp = "yes";

        hide-identity = "yes";
        hide-version = "yes";

        harden-glue = "yes";
        harden-referral-path = "yes";
        harden-algo-downgrade = "yes";
        harden-below-nxdomain = "yes";
        harden-dnssec-stripped = "yes";

        use-caps-for-id = "no";
        qname-minimisation = "yes";

        verbosity = 1;
        log-queries = "yes";
        log-replies = "yes";
        statistics-interval = 0;

        pad-queries = "yes";
        pad-queries-block-size = 128;

        auto-trust-anchor-file = "/var/lib/unbound/root.key";
        val-clean-additional = "yes";

        infra-host-ttl = 60;
        infra-cache-numhosts = 10000;
      };

      forward-zone = [
        {
          name = ".";
          forward-tls-upstream = false;
          forward-addr = [ "127.0.0.1@5300" ];
        }
      ];
    };
  };
}