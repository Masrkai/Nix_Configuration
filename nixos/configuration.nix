{ config, lib, pkgs, ... }:

let
  #unstable = import <unstable> {config.allowUnfree = true;};
  secrets = import ./secrets.nix;
in {
    imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  #Experimental Features
  nix.settings.experimental-features = [ "nix-command" ];

  # Bootloader.
  boot.supportedFilesystems = [ "ntfs" ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Set your time zone.
  time.timeZone = "Africa/Cairo";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_TIME = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_ADDRESS = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
  };

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  # Configure keymap in X11
  services.xserver = {
    enable = false;
    xkb.layout = "us";
    xkb.variant = "";

    videoDrivers = [ "intel" "amdgpu" ];
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  security.rtkit.enable = true;
  hardware.pulseaudio.enable = false;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # Enable bluetooth
  hardware.bluetooth.enable = true ;
  hardware.bluetooth.powerOnBoot = false ;

  # Enable touchpad support
  services.libinput.enable = true;


#*#########################
#* Networking-Configration:
#*#########################

  networking.hostName = "NixOS"; # Defining hostname.
  networking.networkmanager.enable = true;
  networking.usePredictableInterfaceNames = false ;

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 443 8888  8384  22000 18081 /*#Syncthing */  ];
  networking.firewall.allowedUDPPorts = [ 443 22000 21027 18081 /*#Syncthing */ ];


  # Configure network proxy if necessary
  #networking.proxy.default = "https://88.198.212.86:3128/";
  #networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";


#!###############
#! AMD-Graphics:
#!###############

  # GPU drivers and Vulkan support
  hardware.opengl = {
    enable = true;

    driSupport = true;
    driSupport32Bit = true;

  extraPackages  = with pkgs; [
    mesa
    libva
    amdvlk
    vaapiIntel
    vulkan-tools
    vulkan-loader
    intel-media-driver
    ];
  };

  # Add Vulkan ICDs
  environment.variables.AMD_VULKAN_ICD = "RADV";
  environment.variables.VULKAN_ICD_FILENAMES = "${pkgs.vulkan-loader}/share/vulkan/icd.d/radeon_icd.x86_64.json:${pkgs.vulkan-loader}/share/vulkan/icd.d/intel_icd.x86_64.json"; #MASRKAI
#########################################################################################################################################################################################



  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.masrkai = {
    isNormalUser = true;
    description = "Masrkai";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" ];
  };

# Managing unfree packages & Flatpak
nixpkgs.config = {
  allowUnfree = true;
};
services.flatpak.enable = false;


#-> Fonts
fonts.packages = with pkgs; [
  #!First Class
  nerdfonts
  iosevka-bin

  #>Second Class
  noto-fonts
  noto-fonts-cjk
  liberation_ttf
];


environment.systemPackages = with pkgs; [
#############
#Development:
#############

  #->General
  bat
  eza
  git
  file
  xterm
  searxng
  git-lfs
  thermald
  vscodium
  rustdesk-flutter

  #->Phone
  scrcpy
  android-tools

  #-> Python
    (python311.withPackages (pk: with pk; [
      pip
      nltk
      tqdm
      scapy
      pandas
      netaddr
      requests
      colorama
      netifaces
      ipykernel
      setuptools
      python-dotenv
      terminaltables
      huggingface-hub
      pyinstaller-versionfile
      ]
    )
  )

  #-> C++
  gcc
  cmake
  clang
  gnumake
  clang-tools

  #-> Rust #Rust is a very special case and it's packaged by default in Nix DW about it
  rustup

  #-> MicroChips
  esptool
  usbutils
  esptool-ck
  arduino-ide
  arduino-core


#*#########################
#* Vscodium Configuration:
#*#########################
  (vscode-with-extensions.override {
    vscode = vscodium;
    vscodeExtensions = with vscode-extensions; [

                            #* Python
                            ms-python.python
                            ms-python.debugpy

                            #* Nix
                            jnoortheen.nix-ide

                            #* General
                            formulahendry.code-runner
                            shardulm94.trailing-spaces

                            #* VS-Codium Specific
                            ms-vscode-remote.remote-ssh
    ]
++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [ {  name = "remote-ssh-edit";
                                                          publisher = "ms-vscode-remote";
                                                          version = "0.47.2";
                                                          sha256 = "1hp6gjh4xp2m1xlm1jsdzxw9d8frkiidhph6nvl24d0h8z34w49g"; } ];
  })


#?#############
#? User-Daily:
#?#############
  btop
  kooha
  brave
  haruna
  jackett
  ani-cli
  fastfetch
  syncthing
  noisetorch
  betterbird
  qbittorrent
  signal-desktop
  libsForQt5.kdeconnect-kde

  #Productivity
  anytype
  libreoffice-qt
  gimp-with-plugins

  #Gaming
  mesa
  vkd3d
  heroic
  dxvk_2
  bottles
  winetricks
  wineWowPackages.full

  #Games
  mindustry-wayland

  #System
  tlp
  mlocate
  pciutils
  authenticator
  translate-shell
  libsForQt5.spectacle
  libsForQt5.plasma-integration

  #Spell_check
  aspell
  aspellDicts.en
  aspellDicts.en-science
  aspellDicts.en-computers


#!####################
#! Pentration-Testing:
#!####################
  iw
  mdk4
  tshark
  crunch
  asleap
  openssl
  linssid
  dnsmasq
  tcpdump
  lighttpd
  ettercap
  bettercap
  wireshark
  aircrack-ng
  linux-wifi-hotspot


#>################
#> Virtualization:
#>################
  qemu
  qemu-utils
  virt-manager
];


##################
#Listing services:
##################
#--> TLP enabling
services.tlp = {
  enable = true;
  settings = {

  WOL_DISABLE=true;
  WIFI_PWR_ON_AC=false;
  WIFI_PWR_ON_BAT=false;

  USB_AUTOSUSPEND=1;

  USB_EXCLUDE_WWAN=0;
  USB_EXCLUDE_AUDIO=1;
  USB_EXCLUDE_PHONE=1;
  USB_EXCLUDE_PRINTER=1;

  CPU_SCALING_GOVERNOR_ON_AC = "performance";
  CPU_SCALING_GOVERNOR_ON_BAT = "balanced";

  CPU_ENERGY_PERF_POLICY_ON_AC = "balance_power";
  CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";

  #CPU_MIN_PERF_ON_AC = 10;
  #CPU_MAX_PERF_ON_AC = 65;

  #CPU_MIN_PERF_ON_BAT = 0;
  #CPU_MAX_PERF_ON_BAT = 75;

  CPU_BOOST_ON_AC=1;
  CPU_BOOST_ON_BAT=0;

  #CPU_HWP_DYN_BOOST_ON_AC=1;
  #CPU_HWP_DYN_BOOST_ON_BAT=0;

  #Optional helps save long term battery health
  START_CHARGE_THRESH_BAT0 = 95;
  STOP_CHARGE_THRESH_BAT0 = 100;
  };
};


#!#################
#! POWER services:
#!#################

#--> Disabled Power-Profiles for TLP to take action.
  services.power-profiles-daemon.enable = false;

#--> Enable powertop
  powerManagement.powertop.enable = true;

#--> Enable thermald (only necessary if on Intel CPUs)
  services.thermald.enable = true;

#--> Better scheduling for CPU cycles
  services.system76-scheduler.settings.cfsProfiles.enable = true;

#?########################
#? Applications services:
#?########################

#--> KDE connect Specific
  programs.kdeconnect.enable = true;

#--> NoiseTorch
  programs.noisetorch.enable = true;

#--> mlocate // "updatedb & locate"
  services.locate.package   = pkgs.mlocate;
  services.locate.localuser = null;
  services.locate.enable    = true;

#---> Qemu KVM
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable   = true;

#---> Syncthing
  services = {
  syncthing = {
     enable = true;
     user = "masrkai";
     dataDir = "/home/masrkai";
     configDir = "/home/masrkai/Documents/.config/syncthing";
  };
};

#--->Nginx
# services.nginx = {
#   enable = true;
#   virtualHosts."localhost" = {
#     listen = [{ addr = "127.0.0.1"; port = 443; ssl = true; }];
#     sslCertificate = secrets.Nginx-ssl-Certificate;
#     sslCertificateKey = secrets.Nginx-ssl-Certificate-Key;
#     locations."/" = {
#       proxyPass = "http://127.0.0.1:8888";
#     };
#   };
# };

#---> SearXNG
  services.searx = {
    enable = true;
    settings = {
      server = {
        port = 8888;
        bind_address = "127.0.0.1";
        secret_key   = secrets.searx-secret-key;
        base_url     = "http://localhost/";
      };
      ui = {
        default_theme  = "simple";
        default_locale = "en";
      };
      search = {
        safe_search = 0;  # 0: None, 1: Moderate, 2: Strict
        autocomplete = "duckduckgo";
        default_lang = "en";
      };
      engines = [
        { name = "google"; engine = "google"; disabled = false; }
        { name = "duckduckgo"; engine = "duckduckgo"; disabled = false; }
        { name = "wikipedia"; engine = "wikipedia"; disabled = false; }
      ];
      outgoing = {
        request_timeout = 6.0;
        max_request_timeout = 15.0;
      };
      cache = {
        cache_dir = "/var/cache/searx";
      };
    };
  };

#---> Qbit_torrent x Jackett
  services.jackett = {
    dataDir = "/var/lib/jackett";
    enable = true;
    openFirewall = false; # Optional, if you want to open firewall ports for Jackett
  };

#*#########
#* System:
#*#########
#--> $PATH
environment.localBinInPath = true;

#!###############
#! NixOS Version:
#!###############
  system.stateVersion = "24.05";
}
