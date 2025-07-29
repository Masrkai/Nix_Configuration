{ config, lib, pkgs, modulesPath, ... }:

let
  unstable = import <unstable> {config.allowUnfree = true;};
  secrets = import ./Sec/secrets.nix;

  customPackages = {
    #? .Nix
    jsql = pkgs.callPackage ./Programs/Packages/jsql.nix {};
    lm-studio = pkgs.callPackage ./Programs/Packages/lm-studio.nix {};
    wifi-honey = pkgs.callPackage ./Programs/Packages/wifi-honey.nix {};
    hostapd-wpe = pkgs.callPackage ./Programs/Packages/hostapd-wpe.nix {};
    logisim-evolution = pkgs.callPackage ./Programs/Packages/logisim-evolution.nix {};
    super-productivity = pkgs.callPackage ./Programs/Packages/super-productivity.nix {};

    #! Bash
    backup = pkgs.callPackage ./Programs/custom/backup.nix {};
    setupcpp = pkgs.callPackage ./Programs/custom/setupcpp.nix {};

    #? Python
    ctj = pkgs.callPackage ./Programs/custom/ctj.nix {};
    MD-PDF = pkgs.callPackage ./Programs/custom/MD-PDF.nix {};
    evillimiter = pkgs.callPackage ./Programs/Packages/evillimiter.nix {};
    mac-formatter = pkgs.callPackage ./Programs/custom/mac-formatter.nix {};

    #>! Binary / FHSenv
    proton-ge-bin = pkgs.callPackage ./Programs/Packages/proton-ge-bin.nix {};
    grayjay-bin = pkgs.callPackage ./Programs/Packages/grayjay-desktop/grayjay-bin2.nix {};


    #? GO
    evilginx = pkgs.callPackage ./Programs/Packages/evilginx.nix {};

  };

in

{
    imports = [
      ./bash.nix
      ./desktop.nix
      ./systemd.nix
      ./graphics.nix
      ./security.nix
      ./Dev/ztop.nix
      # ./virtualisation.nix
      ./dev-shells/collector.nix
      ./Networking/Networking.nix
      ./hardware-configuration.nix


      #* Services
      ./Services/ztop.nix
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
                        "video" "audio" "power"
                        "ollama"
                        "libvirtd" "kvm" "ubridge"  #* Virtualization

                        "tty" "dialout"             #* Allow access to serial device (for Arduino dev)
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
      nerd-fonts.iosevka
      nerd-fonts.iosevka-term
      material-design-icons

      #> Second Class
      dejavu_fonts
      liberation_ttf

        # Corporate fonts
        vista-fonts

        noto-fonts
        noto-fonts-emoji
        noto-fonts-cjk-sans
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

      cores = 12;                       # Restrict builds to use only N cores 0 to use all.
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

        # realtime-stt = super.pythonPackages.callPackage ./Programs/Packages/RealtimeSTT.nix {};
      })
    ];
    #-------------------------------------------------------------------->
    config = {
      allowUnfree = true;
      # allowBroken = true;

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
  # customPackages.hostapd-wpe
  customPackages.mac-formatter
  customPackages.logisim-evolution
  # customPackages.super-productivity
  customPackages.evillimiter
  # customPackages.evilginx
  # customPackages.grayjay-bin
  #customPackages.airgeddon
  #customPackages.custom-httrack

  unstable.grayjay

  searxng
  nix-prefetch-git
  nixos-generators

  #-> General
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
  htop
  btop
  powertop
  bandwhich
  dmidecode
  gsmartcontrol
  mission-center
  nvtopPackages.nvidia

   #-> Repair
  woeusb
   ntfs3g #? Needed by woeusb
  #  ventoy  #! this is a security concern after the XZ utils events

  #-> Content
  kew
  fzf
  yt-dlp
  haruna
  amberol
  syncthing
  qbittorrent

  unstable.ani-cli
    mpv               #! Needed for ani-cli operation


  brave
  # logseq
  # webcord
  keepassxc
  fastfetch
  authenticator
  signal-desktop

  #-> Archivers
  pv
  # xz
  pigz
  tarlz
  p7zip

  #-> Audio
  pamixer
  alsa-tools
  pavucontrol

  #-> Maintenance Utilities
  gparted #!has issues
  unstable.qdiskinfo
  gnome-disk-utility

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
  affine
  # blender
  thunderbird-bin
  libreoffice-qt6-still
    hunspell
    hunspellDicts.en_US
  # onlyoffice-desktopeditors

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
  unciv
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
  #> Terminals
  xterm

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

  #> DoS
  hping

  #> Wireless
  mdk4
  airgorah
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

  #> Evil Twin

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

  #--> Git // LFS
    programs.git = {
      enable = true;
      lfs = {
        enable = true;
        package = pkgs.git-lfs;
      };

      config = {
        # Set your global git configuration here
        user = {
          name = "Masrkai";
          email = secrets.Email;
        };
        # user.name = "Masrkai";
        # user.email = secrets.Email;
        # Add any other git config options you want
        # init.defaultBranch = "main";
        # You can add more git configurations here
        init.defaultBranch = "main";
        safe.directory = "/etc/nixos";
        # safe.directory = "/home/yourusername/.dotfiles";
      };

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
      # localuser = null;
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


  # #---> Colord
  # services.colord.enable = true;



  #> Steam
  programs.steam = {
    enable = true;
    extest.enable = false;
      extraCompatPackages = with pkgs; [
        customPackages.proton-ge-bin
      ];
    gamescopeSession.enable = true;

    remotePlay.openFirewall = false; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = false; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = false; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  programs.gamescope.enable = true;

  programs.gamemode.enable = true;


  programs.obs-studio = {
    enable = true;
    enableVirtualCamera = true;

    # optional Nvidia hardware acceleration
    package = (
      pkgs.obs-studio.override {
        cudaSupport = true;
      }
    );

    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      input-overlay
      obs-backgroundremoval
      obs-pipewire-audio-capture

      # obs-vaapi #optional AMD hardware acceleration
      obs-gstreamer
      obs-vkcapture
    ];
  };


  #---> Enable CUPS to print documents.
  services.printing.enable = false;

  #--> NoiseTorch: Real-Time Microphone Noise Suppression
  programs.noisetorch.enable = true;

  system.stateVersion = "25.05";
}
