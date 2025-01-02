{ config, lib, pkgs, modulesPath, ... }:

let
  unstable = import <unstable> {config.allowUnfree = true;};
  secrets = import ./Sec/secrets.nix;

  customPackages = {
    #? .Nix
    #airgeddon = pkgs.callPackage ./Programs/Packages/airgeddon.nix {};
    wifi-honey = pkgs.callPackage ./Programs/Packages/wifi-honey.nix {};
    hostapd-wpe = pkgs.callPackage ./Programs/Packages/hostapd-wpe.nix {};
    logisim-evolution = pkgs.callPackage ./Programs/Packages/logisim-evolution.nix {};
    super-productivity = pkgs.callPackage ./Programs/Packages/super-productivity.nix {};
    #custom-httrack = pkgs.libsForQt5.callPackage ./Programs/Packages/custom-httrack.nix {};

    #! Bash
    backup = pkgs.callPackage ./Programs/custom/backup.nix {};
    setupcpp = pkgs.callPackage ./Programs/custom/setupcpp.nix {};

    #? Python
    ctj = pkgs.callPackage ./Programs/custom/ctj.nix {};
    MD-PDF = pkgs.callPackage ./Programs/custom/MD-PDF.nix {};

  };

in

{
    imports = [
      ./hardware-configuration.nix
      ./virtualisation.nix
      ./networking.nix
      ./graphics.nix
      ./security.nix
      ./systemd.nix
      ./desktop.nix
      ./bash.nix
    ];


  time.timeZone = "Africa/Cairo";   #? Set your time zone.
  i18n={
    #? Select internationalisation properties.
    defaultLocale = "en_US.UTF-8";
      supportedLocales = [
      "C.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
      "ru_RU.UTF-8/UTF-8"
      "ar_EG.UTF-8/UTF-8"
      "de_DE.UTF-8/UTF-8"
      ];

    extraLocaleSettings = {
    LC_TIME = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_ADDRESS = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
  }; };

    users.users.masrkai = {
        isNormalUser = true;
        description = "Masrkai";
        extraGroups = [
                        "networkmanager" "bluetooth"
                        "wheel"
                        "qbittorrent" "jackett"
                        "wireshark"
                        "libvirtd" "kvm" "ubridge"
                        "video" "audio" "power"
                        "ollama"
                      ];
      };

    environment={
      #? Set up environment variables for colored man pages
      variables = {
      MANPAGER = lib.mkForce "sh -c 'col -bx | bat -l man -p'";           #* Use bat as the pager for man with syntax highlighting
      LESSOPEN = lib.mkForce "| ${pkgs.lesspipe}/bin/lesspipe.sh %s";     #* Set LESSOPEN to use lesspipe
      LESS = lib.mkForce "-R";                                            #* Ensure LESS is configured to interpret ANSI color codes correctly
      MANROFFOPT = "-c";                                                  #* Enable colorized output for man pages
      # localBinInPath = true;

      CPLUS_INCLUDE_PATH = let
        includeDirs = [
          "${pkgs.eigen}/include/eigen3"
          "${pkgs.nlohmann_json}/include"
          "${pkgs.boost185.dev}/include/"
        ];
      in builtins.concatStringsSep ":" includeDirs;

      LIBRARY_PATH = let
        libDirs = [
          "${pkgs.eigen}/lib"
          "${pkgs.nlohmann_json}/lib"
          "${pkgs.boost185}/lib"
        ];
      in builtins.concatStringsSep ":" libDirs;
     };

      # sessionVariables = {
      #   NIXOS_OZONE_WL = "1";
      #   XDG_SESSION_TYPE = "wayland";
      #   XDG_RUNTIME_DIR = "/run/user/$UID";

      #   #QT_QPA_PLATFORM = "wayland";
      #   GDK_BACKEND = "wayland";
      #   WLR_NO_HARDWARE_CURSORS = "1";
      # };
    };

  programs.less = {
    enable = true;
    envVariables = {
      LESS = "-R --use-color -Dd+r$Du+b";
    };
  };


    services.journald = {
    # Controls repeated message filtering
    rateLimitInterval = "30s";
    rateLimitBurst =  10000;
    extraConfig = ''
      # Compress logs to save space
      Compress=yes

      # Optional: Set max log size and retention
      SystemMaxUse=2G
      MaxRetentionSec=1week
    '';
  };


  #! Diable flatpack
  services.flatpak.enable = lib.mkForce false;

  fonts = {
    packages = with pkgs; [

      #* First Class
      iosevka-bin
      material-design-icons

      #> Second Class
      noto-fonts
      dejavu_fonts
      liberation_ttf
      noto-fonts-emoji
      noto-fonts-cjk-sans
      (nerdfonts.override { fonts = [ "Iosevka" ]; })
      ];

      fontconfig = {
        enable = true;
        defaultFonts = {
          monospace = [ "Iosevka Nerd Font" "Iosevka" ];
          sansSerif = [ "DejaVu Sans" ];
          serif = [ "DejaVu Serif" ];
          emoji = [ "Noto Color Emoji" ];
        };
      };
  };

  nix = {
  settings = {
      # Enable sandboxing if not already enabled (it helps isolate builds).
      sandbox = true;

      # Limit the number of parallel build jobs (default: all available cores).
      max-jobs = 2;

      # Optionally limit CPU usage by controlling core availability.
      cores = 0; # Restrict builds to use only 4 cores.

      system-features = [ "big-parallel" "cuda" "kvm" ];

      # substituters = [
      #   "https://cuda-maintainers.cachix.org"
      # ];
      # trusted-public-keys = [
      #   "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      # ];
    };
  };

  nixpkgs = {
    overlays = [
     (self: super: {
      filterOutX11 = super.lib.filterAttrs (name: pkg:
        !(self.lib.strings.contains "libX11" (toString pkg) || self.lib.strings.contains "xset" (toString pkg) || self.lib.strings.contains "x11-utils" (toString pkg) )) super;

      jax = super.python312Packages.jax.override {
        torch = super.python312Packages.torchWithCuda;
      };

      torchWithCuda = super.python312Packages.torchWithCuda.override {
        magma = super.magma-cuda;
      };

      realtime-stt = super.python311Packages.callPackage ./Programs/Packages/RealtimeSTT.nix {};
      })
    ];
    #-------------------------------------------------------------------->
    config= {
    allowUnfree = true;
        permittedInsecurePackages = [
        "electron-27.3.11"
        "qbittorrent-4.6.4"
        ];
        # packageOverrides = pkgs: {
        #  xorg = null;
        # };
    };
  };




 environment.systemPackages = with pkgs; [
  #*############
  #*Development:
  #*############

  #-> Custom
  customPackages.ctj
  customPackages.MD-PDF
  customPackages.backup
  customPackages.setupcpp
  customPackages.wifi-honey
  customPackages.hostapd-wpe
  customPackages.logisim-evolution
  customPackages.super-productivity
  #customPackages.airgeddon
  #customPackages.custom-httrack

  fan2go
  lm_sensors

  searxng
  nix-prefetch-git
  nixos-generators

  #-> General
    #-! GNS3 Specific Bullshit
    vpcs
    ubridge
    gns3-gui
    dynamips
    gns3-server

  bat
  eza
  git
  acpi
  wget
  less
  most
  kitty
  unzip
  #xterm
  gparted #!has issues
  glxinfo
  git-lfs
  pciutils
  hw-probe
  unrar-wrapper
  rustdesk-flutter
  (lowPrio bash-completion)

  #-> Engineering
  #kicad
  #freecad

  #-> Phone
  scrcpy
  android-tools

  nodePackages.katex

  #-> Python
    (python312.withPackages (pk: with pk; [
        #> Basics
        pip
        pylint
        python-dotenv
        terminaltables
        pyinstaller-versionfile

        h5py
        lxml
        tqdm
        scapy
        curio
        numpy
        pandas
        pyvips
        sqlite
        netaddr
        openusd
        networkx
        openpyxl
        requests
        colorama
        netifaces
        markdown2
        matplotlib
        weasyprint
        setuptools
        markdown-it-py

        #-> Ai
        nltk
        # pydub
        datasets
        # speechbrain
        # transformers
        opencv-python

        # jax
        # torchWithCuda
        # tensorflow-bin

          #> UI
          # gradio
          streamlit

          #> Platforms
          openai
          huggingface-hub
          # google-cloud-texttospeech

          #> speechrecognition
          soundfile
          realtime-stt
          arabic-reshaper

        #-> Juniper/jupter
        notebook
        jupyterlab

        ipykernel
        ipython-sql
        ipython-genutils

        beautifulsoup4
        types-beautifulsoup4
        ]
      )
    )

  #-> C++
  #? Builders
  cmake
  ninja
  gnumake
  cppcheck
  pkg-config

  qtcreator
  kdePackages.qtbase
  kdePackages.qttools

  #? Libraries
  eigen
  nlohmann_json

  boost185.dev
  (hiPrio boost185)

  #! Compilers + Extras
  (lowPrio gdb)
  (hiPrio gcc)

  clang-tools
  clang-analyzer
  (lowPrio clang_18)

  #-> Rust
  rustc
  cargo
  clippy
  rustfmt
  rust-analyzer

  #-> MicroChips
  esptool
  usbutils
  esptool-ck
  arduino-ide
  arduino-core

  #-> Nix
  nixd
  alejandra

  direnv
  nix-tree
  nix-direnv
  nix-output-monitor

  #-->UML
  mermerd

#*#########################
#* Vscodium Configuration:
#*#########################
  (vscode-with-extensions.override {
    vscode = vscodium;
    vscodeExtensions = with vscode-extensions; [

                            #* C++
                            twxs.cmake
                            vadimcn.vscode-lldb
                            llvm-vs-code-extensions.vscode-clangd

                            #* Rust
                            rust-lang.rust-analyzer

                            #* Python
                            ms-python.python
                            ms-python.debugpy
                            ms-python.vscode-pylance

                              #->Jupyter
                              ms-toolsai.jupyter
                              ms-toolsai.jupyter-keymap
                              ms-toolsai.jupyter-renderers
                              ms-toolsai.vscode-jupyter-slideshow
                              ms-toolsai.vscode-jupyter-cell-tags

                            #* Nix
                            mkhl.direnv
                            jnoortheen.nix-ide
                            arrterian.nix-env-selector

                            #* HTML
                            # ms-vscode.live-server
                            vscode-extensions.ritwickdey.liveserver

                            #* Bash
                            mads-hartmann.bash-ide-vscode

                            #* Markdown
                            bierner.markdown-mermaid
                            shd101wyy.markdown-preview-enhanced

                            #* Yamal
                            redhat.vscode-yaml

                            #* General
                            usernamehw.errorlens
                            donjayamanne.githistory      #> GIT History
                            mechatroner.rainbow-csv      #> For .csv files!
                            formulahendry.code-runner
                            shardulm94.trailing-spaces
                            aaron-bond.better-comments
                            streetsidesoftware.code-spell-checker

                            #? theming
                            pkief.material-icon-theme

                            #* VS-Codium Specific
                            editorconfig.editorconfig
                            ms-vscode-remote.remote-ssh
                            github.vscode-pull-request-github
    ]
    ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
                                                        {
                                                          name = "remote-ssh-edit";
                                                          publisher = "ms-vscode-remote";
                                                          version = "0.47.2";
                                                          hash = "sha256-LxFOxkcQNCLotgZe2GKc2aGWeP9Ny1BpD1XcTqB85sI=";
                                                        }
                                                        {
                                                         #https://open-vsx.org/extension/lukinco/lukin-vscode-theme
                                                          name = "lukin-vscode-theme";
                                                          publisher = "lukinco";
                                                          version = "0.1.5";
                                                          hash = "sha256-T6yCPCy2AprDqNTJk2ucN2EsCrODn4j/1oldSnQNigU=";
                                                        }
                                                        {
                                                          #https://open-vsx.org/extension/eliostruyf/screendown
                                                          name = "screendown";
                                                          publisher = "eliostruyf";
                                                          version = "0.0.23";
                                                          hash = "sha256-ZHa4N1QTj7XAizWgeXzRGohhsSbxdPJv1rtCib4sQsU=";
                                                        }
                                                        {
                                                          #https://open-vsx.org/extension/KevinRose/vsc-python-indent
                                                          name = "vsc-python-indent";
                                                          publisher = "KevinRose";
                                                          version = "1.18.0";
                                                          hash = "sha256-hiOMcHiW8KFmau7WYli0pFszBBkb6HphZsz+QT5vHv0=";
                                                        }
                                                        {
                                                          #https://open-vsx.org/api/bpruitt-goddard/mermaid-markdown-syntax-highlighting
                                                          name = "mermaid-markdown-syntax-highlighting";
                                                          publisher = "bpruitt-goddard";
                                                          version = "1.6.6";
                                                          hash = "sha256-1WwjGaYNHN6axlprjznF1S8BB4cQLnNFXqi7doQZjrQ=";
                                                        }
                                                        # {
                                                        #   #https://open-vsx.org/extension/TabNine/tabnine-vscode
                                                        #   name = "tabnine-vscode";
                                                        #   publisher = "TabNine";
                                                        #   version = "3.132.0";
                                                        #   hash = "sha256-hwr/lPLOxpraqjyu0MjZd9JxtcruGz7dKA6CVxUZNYw=";
                                                        # }
                                                        {
                                                          #https://open-vsx.org/extension/ultram4rine/vscode-choosealicense
                                                          name = "vscode-choosealicense";
                                                          publisher = "ultram4rine";
                                                          version = "0.9.4";
                                                          hash = "sha256-YmZ1Szvcv3E3q8JVNV1OirXFdYI29a4mR3rnhJfUSMM=";
                                                        }
                                                        {
                                                          #https://marketplace.visualstudio.com/items?itemName=yy0931.vscode-sqlite3-editor
                                                          name = "vscode-sqlite3-editor";
                                                          publisher = "yy0931";
                                                          version = "1.0.189";
                                                          hash = "sha256-zlZTb9zBSWsnZrcYArW1x4hjHzlAp6ITe4TPuUdYazI=";
                                                        }
                                                        {
                                                          #https://open-vsx.org/extension/markwylde/vscode-filesize
                                                          name = "vscode-filesize";
                                                          publisher = "mkxml";
                                                          version = "3.1.0";
                                                          hash = "sha256-5485MjY3kMdeq/Z2mYaNjPj1XA+xRHizMrQDWDLWrf8=";
                                                        }
                                                        {
                                                          # https://marketplace.visualstudio.com/items?itemName=cheshirekow.cmake-format
                                                          name = "cmake-format";
                                                          publisher = "cheshirekow";
                                                          version = "0.6.11";
                                                          hash = "sha256-NdU8J0rkrH5dFcLs8p4n/j2VpSP/X7eSz2j4CMDiYJM=";
                                                        }
                                                        {
                                                          #https://marketplace.visualstudio.com/items?itemName=ms-python.pylint
                                                          name = "pylint";
                                                          publisher = "ms-python";
                                                          version = "2023.11.13481007";  # Check for the latest version
                                                          hash = "sha256-rn+6vT1ZNpjzHwIy6ACkWVvQVCEUWG2abCoirkkpJts=";
                                                        }
                                                        {
                                                          #https://marketplace.visualstudio.com/items?itemName=darkriszty.markdown-table-prettify
                                                          name = "markdown-table-prettify";
                                                          publisher = "darkriszty";
                                                          version = "3.6.0";  # Check for the latest version
                                                          hash = "sha256-FZTiNGSY+8xk3DJsTKQu4AHy1UFvg0gbrzPpjqRlECI=";
                                                        }
                                                        {
                                                          #https://marketplace.visualstudio.com/items?itemName=goessner.mdmath
                                                          name = "mdmath";
                                                          publisher = "goessner";
                                                          version = "2.7.4";  # Check for the latest version
                                                          hash = "sha256-DCh6SG7nckDxWLQvHZzkg3fH0V0KFzmryzSB7XTCj6s=";
                                                        }
                                                        {
                                                          #https://marketplace.visualstudio.com/items?itemName=shellscape.shellscape-brackets
                                                          name = "shellscape-brackets";
                                                          publisher = "shellscape";
                                                          version = "0.1.2";  # Check for the latest version
                                                          hash = "sha256-dcxtgUfn2GhVVyTxd+6mC0bhwMeLUxB6T9mPBUbgxbA=";
                                                        }
                                                        # {
                                                        #   #https://marketplace.visualstudio.com/items?itemName=shellscape.shellscape-rackets
                                                        #   name = "shellscape-brackets";
                                                        #   publisher = "shellscape";
                                                        #   version = "0.1.2";  # Check for the latest version
                                                        #   hash = "sha256-dcxtgUfn2GhVVyTxd+6mC0bhwMeLUxB6T9mPBUbgxbA=";
                                                        # }
    ];
  }
)

#?#############
#? User-Daily:
#?#############
  lmstudio
  # koboldcpp


  fzf
  btop
  kooha
  brave
  yt-dlp
  logseq
  haruna
  amberol
  webcord
  jackett
  powertop
  keepassxc
  fastfetch
  syncthing
  qbittorrent
  authenticator
  mission-center
  signal-desktop
  unstable.ani-cli

  #-> Archivers
  xz
  p7zip
  tarlz

  #-> Audio
  pamixer
  alsa-tools
  pavucontrol

  #-> KDE Specific
  kdePackages.kgamma
  kdePackages.kscreen
  kdePackages.filelight
  kdePackages.colord-kde
  kdePackages.breeze-icons
  kdePackages.kscreenlocker
  kdePackages.plasma-browser-integration

  #Productivity
  gimp
  blender
  thunderbird-bin
  gnome-disk-utility
  libreoffice-qt6-fresh

  #Gaming
  heroic
  lutris
  bottles
  winetricks
  # unstable.proton-ge-bin
  wineWow64Packages.waylandFull

  #Games
  mindustry-wayland

  #System
  mlocate
  pciutils
  translate-shell

  #Spell_check
  aspell
  aspellDicts.en
  aspellDicts.en-science
  aspellDicts.en-computers

  #Documentation
  man-pages
  linux-manual
  man-pages-posix

#!####################
#! Pentration-Testing:
#!####################
  iw
  dig
  mdk4
  tmux
  nmap
  hping
  stubby
  getdns
  crunch
  asleap
  openssl
  linssid
  # dnsmasq
  tcpdump
  iproute2
  arp-scan
  lighttpd
  ettercap
  bettercap
  traceroute
  aircrack-ng
  linux-wifi-hotspot
];


  #?########################
  #? Applications services:
  #?########################

  #--> direnv
    programs.direnv = {
      enable = true;
      loadInNixShell = true;
      nix-direnv.enable = true;
    };

  #--> Wireshark
    programs.wireshark= {
      enable = true;
      package = pkgs.wireshark;
    };


  #--> KDE connect Specific
    programs.kdeconnect = lib.mkForce {
      enable = true;
      package =  pkgs.kdePackages.kdeconnect-kde;
    };

  #--> mlocate // "updatedb & locate"
    services.locate = {
      enable    = true;
      localuser = null;
      package   = pkgs.mlocate;
    };


  #---> SearXNG
  services.searx = {
    enable = true;
    package = pkgs.searxng;
    settings = {
      server = {
        port = 8888;
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
        suspend_on_unavailable = true;
          result_extras = {
          favicon = true;          # Enable website icons
          thumbnail = true;        # Enable result thumbnails
          thumbnail_proxy = true;  # Use a proxy for thumbnails
          };
      };
      engines = [
        { name = "bing"; engine = "bing"; disabled = false; timeout = 6.0; }
        { name = "brave"; engine = "brave"; disabled = false; timeout = 6.0; }
        { name = "google"; engine = "google"; disabled = false; timeout = 6.0; }
        { name = "wikipedia"; engine = "wikipedia"; disabled = false; timeout = 6.0; }
        { name = "duckduckgo"; engine = "duckduckgo"; disabled = false; timeout = 6.0; }
      ];
      outgoing = {
        request_timeout = 10.0;
        max_request_timeout = 15.0;
        pool_connections = 100;  # Increased connection pool
        pool_maxsize = 20;       # Maximum concurrent connections
        dns_resolver = {
          enable = true;
          use_system_resolver = true;
          resolver_address = "127.0.0.1:53";
        };
      };
      cache = {
        cache_dir = "/var/cache/searx";
        cache_max_age = 1440;  # Cache for 24 hours
        cache_disabled_plugins = [];
      };
      privacy = {
        preferences = {
          disable_web_search = false;
          disable_image_search = false;
          disable_map_search = true;
        };
        http_header_anonymization = true;
      };
    };
  };


  #---> Syncthing
  services.syncthing = {
    guiAddress = "127.0.0.1:8384";
    enable = true;
    user = "masrkai";
    dataDir = "/home/masrkai";
    configDir = "/home/masrkai/Documents/.config/syncthing";
    overrideDevices = true; #! Overrides devices added or deleted through the WebUI
    overrideFolders = true; #! Overrides folders added or deleted through the WebUI
    settings = {
      devices = {
        "A71" = { id = "MTQLI6G-AEJW6KJ-VNJVYNP-4MLFCTF-K3A6U2X-FMTBMWW-YVFJFK4-RFLXWAP"; };
        "Tablet" = { id = "5TS7LC7-MUAD4X6-7WGVLGK-UCRTK7O-EATBVA3-HNBTIOJ-2XW2SUT-DAKNSQC"; };
        "Mariam's Laptop G15" = { id ="5BIAHUG-AKR7L3G-OHQZCPD-B4PPAU7-2KXQEUX-OJY22LG-4GVN5BP-TK4G7AM";};
        };
      folders = {

        "College_shit" = {
          path = "~/Documents/College/Current/";
          devices = [ "A71" "Tablet" "Mariam's Laptop G15"  ];
          versioning = {
            type = "simple";
              params = {
              keep = "5"; # Keep 5 versions
              };
          };
          type = "sendonly"; # Make folder send-only
          ignorePaths = [
          ".venv"
          ".**"
          ".*"
          ];
        };


        "Forbidden_Knowledge" = {
          path = "~/Documents/Books/";
          devices = [ "A71" ];
          versioning = {
            type = "simple";
              params = {
              keep = "5"; # Keep 5 versions
              };
          };
          type = "sendonly"; # Make folder send-only
        };



        "Music" = {
          path = "~/Music/";
          devices = [ "A71" ];
          ignorePerms = false;
          # Add ignore patterns here
          ignorePaths = [
          # Common patterns
          ".git"
          "*.tmp"
          "*.temp"
          "node_modules"
          #? Music crap

          "/Telegram"
          ".thumbnails"
          "/.thumbnails"
          ];
        };


      };
    };
  };


  # #---> Colord
  # services.colord.enable = true;

  #---> Qbit_torrent x Jackett
    services.jackett = {
      enable = true;
      openFirewall = false;
      dataDir = "/var/lib/jackett";
    };

  #---> Enable CUPS to print documents.
  services.printing.enable = false;

  #--> NoiseTorch: Real-Time Microphone Noise Suppression
  programs.noisetorch.enable = true;

  #--> Better scheduling for better CPU cycles & audio performance
  services.system76-scheduler = {
    enable = true;
    settings.cfsProfiles.enable = true; #? Enable CPU scheduling improvements for Audio
  };

  security.rtkit.enable = true;         #? Allow real-time priorities for audio tasks

  # PipeWire Setup
  services.pipewire = {
    enable = true;
    audio.enable = true;         # Makes PipeWire the primary sound server

    wireplumber.enable =true;    # WirePlumber: Session Manager for PipeWire

    #! compatibility / integration
    alsa.enable = true;          # ALSA integration
    pulse.enable = true;         # PulseAudio compatibility
    jack.enable = true;          # JACK support for advanced audio workflows
  };

  services.asusd= {
    enable = true;
    enableUserService = true;

  };

  services.udev.extraRules = ''
  ACTION=="add", SUBSYSTEM=="pci", DRIVER=="pcieport", ATTR{power/wakeup}="disabled"

  # Disable XHC USB controllers from waking up the system
  ACTION=="add", SUBSYSTEM=="pci", DRIVER=="xhci_hcd", ATTR{power/wakeup}="disabled"
  ACTION=="add", SUBSYSTEM=="usb", ATTR{power/wakeup}="disabled"
  '';

      #->Kitty terminal
      environment.etc."xdg/kitty/kitty.conf".text = ''
      # Basic settings
      font_family  Iosevka Fixed Hv Ex Obl
      font_size 13

      # Adjust this value as needed
      modify_font cell_height 90%
      adjust_column_width 0
      disable_ligatures never

      # Scroll settings
      scrollback_lines 10000
      mouse_wheel_scroll yes

      # Use additional symbols from Material Design Icons
      symbol_map U+E000-U+E7C5 Iosevka Nerd Font

      clipboard_control write-clipboard read-clipboard
      GLFW_IM_MODULE=ibus

      # Color scheme
      background #000000
      foreground #ffffff
      cursor #93a1a1

      # Window layout
      remember_window_size no
      initial_window_width 177c
      initial_window_height 36c

      # Tab bar
      tab_bar_edge bottom
      tab_bar_style powerline

      # Performance
      repaint_delay 10
      input_delay 3
      sync_to_monitor yes

      # Key mappings
      map ctrl+shift+c copy_to_clipboard
      map ctrl+shift+v paste_from_clipboard
      map ctrl+shift+t new_tab
      map ctrl+shift+q close_tab

      # Search key mappings
      map ctrl+shift+f launch --type=overlay --stdin-source=@screen_scrollback /bin/sh -c 'fzf --ansi --no-sort --no-mouse --exact -i --tac --preview "echo {} | bat --color=always --plain --language=sh" --preview-window=right:50%:wrap | kitty +kitten clipboard'
      map ctrl+shift+/ show_scrollback
      map ctrl+shift+g show_last_command_output

      # Alternative search with bat highlighting
      map ctrl+shift+b launch --type=overlay --stdin-source=@screen_scrollback /bin/sh -c 'bat --color=always --plain | fzf --ansi --no-sort --no-mouse --exact -i --tac | kitty +kitten clipboard'

      # Initial zoom level (optional)
      initial_zoom_level 0.75
    '';

    system.stateVersion = "24.11";

}
