{ config, lib, pkgs, modulesPath, ... }:

let
  unstable = import <unstable> {config.allowUnfree = true;};
  secrets = import ./Sec/secrets.nix;

  customPackages = {
    #? .Nix
    lm-studio = pkgs.callPackage ./Programs/Packages/lm-studio.nix {};
    logisim-evolution = pkgs.callPackage ./Programs/Packages/logisim-evolution.nix {};
    super-productivity = pkgs.callPackage ./Programs/Packages/super-productivity.nix {};

    #>! Binary / FHSenv
    # proton-ge-bin = pkgs.callPackage ./Programs/Packages/proton-ge-bin.nix {};
    grayjay-bin = pkgs.callPackage ./Programs/Packages/grayjay-desktop/grayjay-bin2.nix {};
  };
in
{
    imports = [
      ./desktop.nix
      ./systemd.nix
      ./graphics.nix
      ./security.nix
      ./Dev/ztop.nix
      ./Terminal/bash.nix
      # ./virtualisation.nix
      ./dev-shells/collector.nix
      ./Networking/Networking.nix
      ./hardware-configuration.nix


      ./Programs/custom/ztop.nix


      #* Services
      ./Services/ztop.nix
    ];


  time.timeZone = "Africa/Cairo";   #? Set your time zone.
  i18n={
    #? Select internationalisation properties.
    defaultLocale = "en_US.UTF-8";

    extraLocales =  [
      "C.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
      "ru_RU.UTF-8/UTF-8"
      "ar_EG.UTF-8/UTF-8"
      "de_DE.UTF-8/UTF-8"
    ];

    supportedLocales = [
     "all"
    ];

    extraLocaleSettings = {
    LC_ALL = "en_US.UTF-8";
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
                        # "libvirtd" "kvm" "ubridge"  #* Virtualization

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
      cm_unicode
      newcomputermodern
      nerd-fonts.iosevka
      nerd-fonts.iosevka-term
      material-design-icons

      #> Second Class
      dejavu_fonts
      liberation_ttf

        # Corporate fonts
        vista-fonts
        corefonts

        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-color-emoji
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
      max-jobs = 4;                     # Limit the number of parallel build jobs.
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
        # "electron-27.3.11"
        # "qbittorrent-4.6.4"
        # "electron-35.7.5"
        # "python3.12-ecdsa-0.19.1"
        "ciscoPacketTracer8-8.2.2"

      ];
    };
  };



 environment.systemPackages = with pkgs; [
  #*############
  #*Development:
  #*############

  #-> Custom
  unstable.grayjay
  customPackages.logisim-evolution

  kitty


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


  # pure-ftpd


  unzip
  pciutils
  hw-probe
  unrar-wrapper
  rustdesk-flutter
  # (lib.lowPrio bash-completion)

  #-> Engineering
  #kicad
  #freecad

  #-> Phone
  scrcpy
  android-tools

  #-> MicroChips
  esptool
  usbutils
  esptool-ck
  arduino-ide
  arduino-core

  #-->UML
  mermerd


  # (unstable.pkgs.texlive.combine {
  #   inherit (texlive) scheme-basic
  #   xetex
  #   fontspec
  #   unicode-math
  #   lm
  #   lm-math
  #   iftex
  #   geometry
  #   hyperref
  #   xcolor
  #   amsmath
  #   booktabs
  #   amsfonts
  #   footnoterange

  #   fvextra
  #   fancyvrb
  #   ;
  # })


  (texliveMedium.withPackages (ps: with ps; [
    fontspec

  ]))

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
  qbittorrent

  unstable.ani-cli
    mpv               #! Needed for ani-cli operation


  brave
  keepassxc
  fastfetch
  authenticator
  signal-desktop

  #-> Archivers
  pv
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

  #-> System Utilities
  file
  ethtool
  mlocate
  busybox
  pciutils


  #-> KDE Specific
  kdePackages.kclock
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
  # kooha
  affine
  # blender
  # davinci-resolve
  thunderbird-bin
  libreoffice-qt6-still
    hunspell
    hunspellDicts.en_US

    #-> PDF
    pdfarranger
    pdfmixtool

  mindustry-wayland

  #Spell_check
  aspell
  aspellDicts.en
  aspellDicts.en-science
  aspellDicts.en-computers

  #Documentation
  man-pages
  linux-manual
  man-pages-posix

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

  #--> KDE connect
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


  programs.obs-studio = {
    enable = true;
    enableVirtualCamera = true;

    # optional Nvidia hardware acceleration
    package = (
      pkgs.obs-studio.override {
        cudaSupport = true;
      }
    );

    plugins = with unstable.pkgs.obs-studio-plugins; [
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
