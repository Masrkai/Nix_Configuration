{ config, lib, pkgs, modulesPath, ... }:

let
  secrets = import ../Sec/secrets.nix;
  unstable = import <unstable> {config.allowUnfree = true;};

in
{
  services.ollama = {
    enable = true;
    package = unstable.ollama;
    acceleration = "cuda";

    port = 11434;
    host = "127.0.0.1";

    user = "ollama";
    group = "ollama";
  };

  services.open-webui = {
    enable = false;
    # stateDir = "/var/lib/open-webui";

    package=
         #pkgs.open-webui;
         #unstable.open-webui;
         pkgs.callPackage ../Programs/python-libs/open-webui.nix {};


    port = 8080;
    host = "127.0.0.1";
    openFirewall = true;
    environment = {
      TZ = secrets.TZ;
      WEBUI_AUTH = "False";
      DATA_DIR = "/var/lib/open-webui/data";  # Explicitly set data directory
      OLLAMA_BASE_URL = "http://127.0.0.1:11434";  # Redundant but sometimes helps
      OLLAMA_API_BASE_URL = "http://127.0.0.1:11434/api";

      DO_NOT_TRACK = "True";
        SCARF_NO_ANALYTICS = "True";
        ANONYMIZED_TELEMETRY = "False";
        WEBUI_SESSION_COOKIE_SECURE = "True";
        WEBUI_SESSION_COOKIE_SAME_SITE = "strict";

      #! NONSENSE IN MY HUMBLE OPINION
      ENABLE_OPENAI_API = "False";
      ENABLE_MESSAGE_RATING = "False";
      ENABLE_EVALUATION_ARENA_MODELS = "False";
      ENABLE_AUTOCOMPLETE_GENERATION = "False";
    };

  };


  services.tika = {
    enable = false;
    enableOcr = true;

    port = 9998;
    openFirewall = false;
    listenAddress = "127.0.0.1";
  };

  virtualisation = lib.mkMerge [
    {
      podman = {
        enable = false;
        dockerCompat = true;
        #defaultNetwork.settings.dns_enabled = true;
      };

      # oci-containers = {
      #   backend = "podman";
      #   containers = {
      #     "open-webui" = import ./containers/open-webui.nix;
      #   };
      # };
    }
  ];


  #---> SearXNG
    services.searx = {
      enable = true;
      package = pkgs.searxng;

      faviconsSettings = {
        favicons = {
                cfg_schema = 1;

                  proxy = {
                    # Uncomment and modify as needed:
                    max_age = 5184000;  # 60 days / default: 7 days (604800 sec)

                    resolver_map = {
                      google     = "searx.favicons.resolvers.google";
                      yandex     = "searx.favicons.resolvers.yandex";
                      allesedv   = "searx.favicons.resolvers.allesedv";
                      duckduckgo = "searx.favicons.resolvers.duckduckgo";
                    };
                  };

                  cache = {
                    # Uncomment and modify as needed:
                    db_url = "/var/cache/searxng/faviconcache.db";  # default: "/tmp/faviconcache.db"
                    HOLD_TIME = 5184000;                            # 60 days / default: 30 days
                    LIMIT_TOTAL_BYTES = 2147483648;                 # 2 GB / default: 50 MB
                    BLOB_MAX_BYTES = 40960;                         # 40 KB / default 20 KB
                    MAINTENANCE_MODE = "off";                       # default: "auto"
                    MAINTENANCE_PERIOD = 600;                       # 10min / default: 1h
                  };
        };
      };

      settings = {

        general = {
          instance_name = "Masrkai";
        };

        brand = {
          docs_url         = "";
          wiki_url         = "";
          issue_url        = "";
          new_issue_url    = "";
          public_instances = "";
        };

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
          site_name = "Masrkai";           # Browser tab title
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
          favicon_resolver = "duckduckgo";

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

        plugins = let
          mkPlugin = name: active: { ${name} = { inherit active; }; };
          activePlugins = map (name: mkPlugin name true) [
            "searx.plugins.calculator.SXNGPlugin"
            "searx.plugins.hash_plugin.SXNGPlugin"
            "searx.plugins.self_info.SXNGPlugin"
            "searx.plugins.tracker_url_remover.SXNGPlugin"
            "searx.plugins.unit_converter.SXNGPlugin"
            "searx.plugins.ahmia_filter.SXNGPlugin"
            "searx.plugins.hostnames.SXNGPlugin"
            "searx.plugins.oa_doi_rewrite.SXNGPlugin"
          ];
          inactivePlugins = map (name: mkPlugin name false) [
          ];
        in
          lib.foldr lib.mergeAttrs {} (activePlugins ++ inactivePlugins);

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
          cache_dir = "/var/cache/searxng";
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