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

    jsql = pkgs.callPackage ./Programs/Packages/jsql.nix {};



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

    #> VENV
    grayjay = pkgs.callPackage ./Programs/Packages/grayjay-desktop/grayjay.nix {};

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
      ./Langs/ztop.nix
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
                        "wheel"
                        "networkmanager" "bluetooth"
                        "wireshark"
                        "qbittorrent" "jackett"
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
      amiri
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
      experimental-features = [
        #"flakes"
        "nix-command"
      ];

      cores = 0;                        # Restrict builds to use only N cores 0 to use all.
      max-jobs = 1;                     # Limit the number of parallel build jobs.
      sandbox = true;                   # Enable sandboxing if not already enabled (it helps isolate builds).
      builders-use-substitutes = true;  # Prefer cached builds
      system-features = [ "big-parallel" "kvm" ];

      trusted-users =[
        "root"
        "@wheel"
        "masrkai"
      ];

      # Keep fewer generations to reduce memory pressure
      keep-derivations = false;
      keep-outputs = false;
    };

    # extraOptions = ''
    # keep-outputs = true
    # keep-derivations = true
    # '';
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
  customPackages.grayjay
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
  sass
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

  #-> MicroChips
  esptool
  usbutils
  esptool-ck
  arduino-ide
  arduino-core

  #-->UML
  mermerd
  texliveMedium

  #-> Benshmarking
  furmark


#?#############
#? User-Daily:
#?#############
  #-> Ai
  # lmstudio
  # customPackages.lm-studio   #? relying on custom package rather than nix packages because they are ancient in release

  # koboldcpp

  #-> Monitoring
  btop
  powertop
  dmidecode
  gsmartcontrol
  mission-center
  nvtopPackages.nvidia

  #-> Content
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
  kdePackages.kdenlive
  kdePackages.filelight
  kdePackages.colord-kde
  kdePackages.breeze-icons
  kdePackages.kscreenlocker
  kdePackages.plasma-browser-integration

  #-> Productivity
  gimp
  kooha
  # blender
  thunderbird-bin
  gnome-disk-utility
  libreoffice-qt6-still

    #-> PDF
    pdfarranger
    pdfmixtool

  #-> Gaming
  lutris
  bottles
  heroic-unwrapped

  dxvk
  # vkd3d
  mangohud

  winetricks
  # wineWowPackages.stableFull

  #Games
  mindustry-wayland

  #System
  mlocate
  busybox
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


  #> Internet basics
  iw
  dig
  nmap
  getdns
  linssid
  tcpdump
  ettercap
  iproute2
  arp-scan
  inetutils
  traceroute

  bettercap
  burpsuite

  #> DOS
  hping

  #> Wireless
  mdk4
  aircrack-ng
  reaverwps-t6x
  linux-wifi-hotspot

  #> Utilities
  tmux
  asleap
  lighttpd

  #> Exploitation
  # armitage
  exploitdb
  metasploit

  #> SQL
  customPackages.jsql
  sqlmap

];

  #?########################
  #? Applications services:
  #?########################

  gtk.iconCache.enable = true;

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

  #--> NextCloud
  environment.etc."nextcloud-admin-pass".text = secrets.nextcloud-admin-pass;
  services.nextcloud = {
    enable = false;
    package = pkgs.nextcloud30;

    extraAppsEnable = true;
      extraApps = {
        inherit (config.services.nextcloud.package.packages.apps) news contacts calendar tasks;

        # memories = pkgs.fetchNextcloudApp {
        #     sha256 = "sha256-Xr1SRSmXo2r8yOGuoMyoXhD0oPVm/0/ISHlmNZpJYsg=";
        #     url = "https://github.com/pulsejet/memories/releases/download/v6.2.2/memories.tar.gz";
        #     license = "agpl3";
        # };
      };

    hostName = "NixOS";
    config.dbtype = "sqlite";
    config.adminpassFile = "/etc/nextcloud-admin-pass";
  };

  #---> Syncthing
  services.syncthing = {
        enable = true;
        user = "masrkai";
        dataDir = "/home/masrkai";
        configDir = "/home/masrkai/Documents/.config/syncthing";

    guiAddress = "127.0.0.1:8384";
    systemService = true;
    overrideDevices = true; #! Overrides devices added or deleted through the WebUI
    overrideFolders = true; #! Overrides folders added or deleted through the WebUI
    openDefaultPorts = true;
    settings = {
      options ={
        urAccepted = -1;
        relaysEnabled = false;
        maxFolderConcurrency = 9;
        localAnnounceEnabled = true;

      };
      devices = {
        "A71" = { id = "MTQLI6G-AEJW6KJ-VNJVYNP-4MLFCTF-K3A6U2X-FMTBMWW-YVFJFK4-RFLXWAP"; };
        "Tablet" = { id = "5TS7LC7-MUAD4X6-7WGVLGK-UCRTK7O-EATBVA3-HNBTIOJ-2XW2SUT-DAKNSQC"; };
        "Mariam's Laptop G15" = { id ="XR63JZR-33WFJNB-PPHDMWF-XF3V5WX-34XHJAB-SIL2L7L-QGPZI2U-BKRIOQO";};
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
    extest.enable = false;
      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
    remotePlay.openFirewall = false; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = false; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = false; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  #---> Enable CUPS to print documents.
  services.printing.enable = false;

  #--> NoiseTorch: Real-Time Microphone Noise Suppression
  programs.noisetorch.enable = true;

  system.stateVersion = "24.11";
}
