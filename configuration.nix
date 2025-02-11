{ config, lib, pkgs, modulesPath, ... }:

let
  unstable = import <unstable> {config.allowUnfree = true;};
  secrets = import ./Sec/secrets.nix;

  customPackages = {
    #? .Nix
    lm-studio = pkgs.callPackage ./Programs/Packages/lm-studio.nix {};
    wifi-honey = pkgs.callPackage ./Programs/Packages/wifi-honey.nix {};
    hostapd-wpe = pkgs.callPackage ./Programs/Packages/hostapd-wpe.nix {};
    logisim-evolution = pkgs.callPackage ./Programs/Packages/logisim-evolution.nix {};
    super-productivity = pkgs.callPackage ./Programs/Packages/super-productivity.nix {};


    #airgeddon = pkgs.callPackage ./Programs/Packages/airgeddon.nix {};
    #custom-httrack = pkgs.libsForQt5.callPackage ./Programs/Packages/custom-httrack.nix {};

    #! Bash
    backup = pkgs.callPackage ./Programs/custom/backup.nix {};
    setupcpp = pkgs.callPackage ./Programs/custom/setupcpp.nix {};

    #? Python
    ctj = pkgs.callPackage ./Programs/custom/ctj.nix {};
    MD-PDF = pkgs.callPackage ./Programs/custom/MD-PDF.nix {};
    evillimiter = pkgs.callPackage ./Programs/Packages/evillimiter.nix {};
    mac-formatter = pkgs.callPackage ./Programs/custom/mac-formatter.nix {};

  };

  # Define common paths
  PyVersion = 312;
  pythonSP = pkgs."python${toString PyVersion}";
  pythonPackages = pkgs."python${toString PyVersion}Packages";


  # inherit (config._module.args.secrets) searx-secret-key;


in

{
    imports = [
      ./Ai.nix
      ./bash.nix
      ./desktop.nix
      ./systemd.nix
      ./graphics.nix
      ./security.nix
      ./virtualisation.nix
      ./dev-shells/collector.nix
      ./Networking/Networking.nix
      ./hardware-configuration.nix

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

      CPLUS_INCLUDE_PATH = let
      #! This environment variable is specifically for header files
      #? Should contain paths to .h and .hpp files
      #* Typically includes /include directories
        includeDirs = [
          "${pkgs.glibc.dev}/include"
          "${pkgs.stdenv.cc.cc.lib}/include"
          "${pkgs.llvmPackages.libcxx}/include/c++/v1"


          "${pkgs.boost185}/include/"
          "${pkgs.eigen}/include/eigen3"
          "${pkgs.nlohmann_json}/include"
        ];
      in builtins.concatStringsSep ":" includeDirs;


      LIBRARY_PATH = let
      #! Used for linking, points to library binary locations
      #? Contains paths to .so and .a files
      #* Typically includes /lib directories
        libDirs = [
          "${pkgs.glibc.dev}/lib"
          "${pkgs.stdenv.cc.cc.lib}/lib"
          "${pkgs.llvmPackages.libcxx}/lib"

          "${pkgs.eigen}/lib"
          "${pkgs.boost185}/lib"
          "${pkgs.nlohmann_json}/lib"
        ];
      in builtins.concatStringsSep ":" libDirs;

      # Compiler configuration
      CC = "gcc";
      CXX = "g++";

      # Additional flags for clang to use libstdc++
      LDFLAGS = lib.mkForce "-L${pkgs.stdenv.cc.cc.lib}/lib";
      CXXFLAGS = lib.mkForce "-stdlib=libstdc++ -I${pkgs.stdenv.cc.cc.lib}/include -I${pkgs.stdenv.cc.cc.lib}/include/c++/13.3.0 -I${pkgs.stdenv.cc.cc.lib}/include/c++/13.3.0/x86_64-unknown-linux-gnu";

      # Other optional environment variables for clang
      CLANG_GCC_TOOLCHAIN = lib.mkForce "${pkgs.stdenv.cc}";
      CLANG_LIBRARY_DIRS = lib.mkForce "${pkgs.llvmPackages.libcxx}/lib";
      CLANG_INCLUDE_DIRS = lib.mkForce "${pkgs.llvmPackages.libcxx}/include/c++/v1";
     };
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
    extraOptions = ''
    keep-outputs = true
    keep-derivations = true
    '';
  };

  nixpkgs = {
    overlays = [
      (self: super: {
        # Rest of your existing configurations
        filterOutX11 = super.lib.filterAttrs (name: pkg:
          !(self.lib.strings.contains "libX11" (toString pkg) ||
            self.lib.strings.contains "xset" (toString pkg) ||
            self.lib.strings.contains "x11-utils" (toString pkg)))
          super;

        jackett = super.jackett.overrideAttrs (oldAttrs: {
          doCheck = false;
        });

        wine = super.wineWowPackages.stableFull.override {
          x11Support = false;
          cupsSupport = false;
          waylandSupport = true;
        };

        # jax = super.pythonPackages.jax.override {
        #   torch = super.pythonPackages.torchWithCuda;
        # };

        # realtime-stt = super.pythonPackages.callPackage ./Programs/Packages/RealtimeSTT.nix {};
      })
    ];
    #-------------------------------------------------------------------->
    config = {
      allowUnfree = true;
      permittedInsecurePackages = [
        "electron-27.3.11"
        "qbittorrent-4.6.4"
      ];
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
  customPackages.mac-formatter
  customPackages.logisim-evolution
  customPackages.super-productivity
  customPackages.evillimiter
  #customPackages.airgeddon
  #customPackages.custom-httrack


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

  git
  git-lfs

  bat
  eza
  acpi
  wget
  less
  most
  kitty
  ghostty


  unzip
  #xterm
  gparted #!has issues
  glxinfo
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

        pyinstaller
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
        # opencv-python

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
          # realtime-stt
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

  #? UIs
  gtk3
  gtk4
  qtcreator
  kdePackages.qtbase
  kdePackages.qttools

  #? Libraries
  eigen
  nlohmann_json

  (hiPrio boost185)

  #! Compilers + Extras

  # Add these C/C++ development essentials
  gcc-unwrapped.lib
  glibc
  glibc.dev

  (lowPrio gdb)
  (hiPrio gcc_multi)

  clang_multi
  clang-tools
  llvmPackages.libcxx

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
  nix-eval-jobs
  nix-output-monitor

  #-->UML
  mermerd
  texliveMedium

#*#########################
#* Vscodium Configuration:
#*#########################
  (vscode-with-extensions.override {
    vscode = vscodium;
    vscodeExtensions = with vscode-extensions; [

                            #* C++
                            twxs.cmake
                            vadimcn.vscode-lldb
                            # llvm-vs-code-extensions.vscode-clangd

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

                                                        # https://open-vsx.org/extension/llvm-vs-code-extensions/vscode-clangd
                                                        {
                                                          name = "vscode-clangd";
                                                          publisher = "llvm-vs-code-extensions";
                                                          version = "0.1.33";
                                                          hash = "sha256-NAQ7qT99vudcb/R55pKY3M5H6sV32aB4P8IWZKVQJas=";
                                                        }
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
  #-> Ai
  # lmstudio
  customPackages.lm-studio   #? relying on custom package rather than nix packages because they are ancient in release

  # koboldcpp

  #-> Monitoring
  btop
  powertop
  dmidecode
  gsmartcontrol
  mission-center
  nvtopPackages.nvidia

  #-> Contrnt
  busybox
  fzf
  yt-dlp
  haruna
  amberol
  syncthing
  qbittorrent
  unstable.ani-cli

  brave
  logseq
  webcord
  keepassxc
  fastfetch
  authenticator
  signal-desktop

  #-> Archivers
  pv
  xz
  pigz
  tarlz
  p7zip

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

  #-> Productivity
  gimp
  kooha
  blender
  # davinci-resolve
  ffmpeg
  thunderbird-bin
  gnome-disk-utility
  libreoffice-qt6-still

  #-> Gaming
  lutris
  bottles
  # proton-ge-bin
  heroic-unwrapped

  dxvk
  vkd3d
  mangohud

  winetricks
  wineWowPackages.stableFull

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

  #> Password cracking
  crunch
  hashcat
  hcxtools
  hcxdumptool
  zip2hashcat
  hashcat-utils



  iw
  dig
  mdk4
  tmux
  nmap
  hping
  stubby
  getdns
  asleap
  linssid

  # armitage
  # metasploit

  tcpdump
  iproute2
  arp-scan
  lighttpd
  ettercap
  bettercap
  traceroute
  aircrack-ng
  reaverwps-t6x
  linux-wifi-hotspot
];

  #?########################
  #? Applications services:
  #?########################

  #--> Appimages supports
  programs.appimage = {
  enable = true;
  binfmt = true;
  };

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
      port = 9117;
      enable = true;
      package = pkgs.jackett;

      user = "jackett" ;
      group = "jackett" ;

      openFirewall = false;

      dataDir = "/var/lib/jackett/";
    };

  #> Steam
  programs.steam = {
    enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
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



  # services.open-webui.enable = true;

  services.udev.extraRules = ''
  ACTION=="add", SUBSYSTEM=="pci", DRIVER=="pcieport", ATTR{power/wakeup}="disabled"

  # Disable XHC USB controllers from waking up the system
  ACTION=="add", SUBSYSTEM=="pci", DRIVER=="xhci_hcd", ATTR{power/wakeup}="disabled"
  ACTION=="add", SUBSYSTEM=="usb", ATTR{power/wakeup}="disabled"
  '';

      #->Kitty terminal
      environment ={
      etc = {
            "xdg/kitty/kitty.conf".text = ''
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
        };
      };

    system.stateVersion = "24.11";
}
