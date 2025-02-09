{ config, lib, pkgs, modulesPath, ... }:

let
  secrets = import ./Sec/secrets.nix;
in
{
  services.ollama = {
    enable = true;
    acceleration = "cuda";

    port = 11434;
    host = "127.0.0.1";

    user = "ollama";
    group = "ollama";
  };

  services.tika = {
    enable = true;
    enableOcr = true;

    port = 9998;
    openFirewall = false;
    listenAddress = "127.0.0.1";
  };

  virtualisation = lib.mkMerge [
    {
      podman = {
        enable = true;
        dockerCompat = true;
        #defaultNetwork.settings.dns_enabled = true;
      };

      oci-containers = {
        backend = "podman";
        containers = {
          "open-webui" = import ./containers/open-webui.nix;
        };
      };
    }
  ];

  system.activationScripts = {
    script.text = ''
      install -d -m 755 ${builtins.getEnv "HOME"}/open-webui/data -o root -g root
    '';
  };

  #---> SearXNG
    services.searx = {
      enable = true;
      package = pkgs.searxng;
      settings = {
        server = {
          port = 8880;
          bind_address = "127.0.0.1";
          base_url = "http://localhost/";
          secret_key = secrets.searx-secret-key;
          limiter = true;  # Enable rate limiting
          ratelimit_low = 30;
          ratelimit_high = 50;
        };
        ui = {
          default_locale = "en";
          default_theme = "simple";
          query_in_title = true;
          infinite_scroll = true;
          engine_shortcuts = true;  # Show engine icons
          expand_results = true;    # Show result thumbnails
          theme_args = {
            style = "auto";  # Supports dark/light mode
          };
        };
        search = {
          safe_search = 0;
          default_lang = "en";
          autocomplete = "duckduckgo";
          suspend_on_unavailable = false;
            result_extras = {
            favicon = true;          # Enable website icons
            thumbnail = true;        # Enable result thumbnails
            thumbnail_proxy = true;  # Use a proxy for thumbnails
            };
            formats = [
              "rss"
              "csv"
              "html"
              "json"
            ];
        };
        engines = [
          { name = "bing";       engine = "bing";       disabled = false; timeout = 6.0; }
          { name = "brave";      engine = "brave";      disabled = false; timeout = 6.0; }
          { name = "google";     engine = "google";     disabled = false; timeout = 6.0; }
          { name = "wikipedia";  engine = "wikipedia";  disabled = false; timeout = 6.0; }
          { name = "duckduckgo"; engine = "duckduckgo"; disabled = false; timeout = 6.0; }
        ];
        outgoing = {
          pool_maxsize = 20;       # Maximum concurrent connections
          request_timeout = 10.0;
          pool_connections = 100;  # Increased connection pool
          max_request_timeout = 15.0;
          dns_resolver = {
            enable = true;
            use_system_resolver = true;
            resolver_address = "127.0.0.1";
          };
        };
        cache = {
          cache_max_age = 1440;  # Cache for 24 hours
          cache_disabled_plugins = [];
          cache_dir = "/var/cache/searx";
        };
        privacy = {
          preferences = {
            disable_map_search = true;
            disable_web_search = false;
            disable_image_search = false;
          };
          http_header_anonymization = true;
        };
      };
    };

}