{ config, lib, pkgs, ... }:

let
  #unstable = import <unstable> {config.allowUnfree = true;};
  secrets = import ./secrets.nix;
in {
    imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./networking.nix
      ./bash.nix
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
  services.xserver.enable = true;  # Set to true for Plasma
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  # Configure keymap in X11
  services.xserver = {
    xkb.variant = "";
    xkb.layout = "us";
    videoDrivers = [ "intel" "amdgpu" ];
  };

  # Enable bluetooth
  hardware.bluetooth.enable = true ;
  hardware.bluetooth.powerOnBoot = false ;

  # Enable touchpad support
  services.libinput.enable = true;


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
  nil
  git
  unzip
  xterm
  gparted
  searxng
  git-lfs
  thermald
  rustdesk-flutter
  bash-completion

  #->Phone
  scrcpy
  android-tools

  #-> Python
    (python311.withPackages (pk: with pk; [
      pip
      nltk
      lxml
      tqdm
      scapy
      numpy
      pandas
      netaddr
      requests
      colorama
      netifaces
      ipykernel
      setuptools
      python-dotenv
      beautifulsoup4
      terminaltables
      huggingface-hub
      types-beautifulsoup4
      pyinstaller-versionfile
      ]
    )
  )

  #-> C++
  (hiPrio gcc)
  cmake
  gnumake
  clang-tools
  (lowPrio clang)

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

                            #* C++
                            twxs.cmake
                            ms-vscode.cmake-tools
                            llvm-vs-code-extensions.vscode-clangd

                            #* Python
                            ms-python.python
                            ms-python.debugpy

                              #->Jupyter
                              ms-toolsai.jupyter
                              ms-toolsai.jupyter-keymap
                              ms-toolsai.jupyter-renderers
                              ms-toolsai.vscode-jupyter-slideshow
                              ms-toolsai.vscode-jupyter-cell-tags

                            #* Nix
                            jnoortheen.nix-ide

                            #* HTML
                            ms-vscode.live-server

                            #* Markdown
                            bierner.markdown-mermaid

                            #* General
                            usernamehw.errorlens
                            donjayamanne.githistory #GIT History
                            grapecity.gc-excelviewer # For Exel Files
                            formulahendry.code-runner
                            shardulm94.trailing-spaces
                            aaron-bond.better-comments
                            streetsidesoftware.code-spell-checker

                            #? theming
                            pkief.material-icon-theme

                            #* VS-Codium Specific
                            ms-vscode-remote.remote-ssh
    ]
++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
                                                       # To generate Hash
                                                       # nix-prefetch-url <Download URL>
                                                       # nix hash to-sri --type sha256 $(nix hash to-base16 --type sha256 <base32-hash>)

                                                        {
                                                          name = "remote-ssh-edit";
                                                          publisher = "ms-vscode-remote";
                                                          version = "0.47.2";
                                                          sha256 = "1hp6gjh4xp2m1xlm1jsdzxw9d8frkiidhph6nvl24d0h8z34w49g";
                                                        }
                                                        {
                                                         #https://open-vsx.org/extension/lukinco/lukin-vscode-theme
                                                          name = "lukin-vscode-theme";
                                                          publisher = "lukinco";
                                                          version = "0.1.5";
                                                          sha256 = "sha256-T6yCPCy2AprDqNTJk2ucN2EsCrODn4j/1oldSnQNigU=";
                                                        }
                                                        {
                                                          #https://open-vsx.org/extension/eliostruyf/screendown
                                                          name = "screendown";
                                                          publisher = "eliostruyf";
                                                          version = "0.0.23";
                                                          sha256 = "sha256-ZHa4N1QTj7XAizWgeXzRGohhsSbxdPJv1rtCib4sQsU=";
                                                        }
                                                        {
                                                          #https://open-vsx.org/extension/KevinRose/vsc-python-indent
                                                          name = "vsc-python-indent";
                                                          publisher = "KevinRose";
                                                          version = "1.18.0";
                                                          sha256 = "sha256-hiOMcHiW8KFmau7WYli0pFszBBkb6HphZsz+QT5vHv0=";
                                                        }
                                                        {
                                                          #https://open-vsx.org/api/bpruitt-goddard/mermaid-markdown-syntax-highlighting/1.6.6/file/bpruitt-goddard.mermaid-markdown-syntax-highlighting-1.6.6.vsix
                                                          name = "mermaid-markdown-syntax-highlighting";
                                                          publisher = "bpruitt-goddard";
                                                          version = "1.6.6";
                                                          sha256 = "sha256-1WwjGaYNHN6axlprjznF1S8BB4cQLnNFXqi7doQZjrQ=";
                                                        }
                                                        {
                                                          #https://open-vsx.org/extension/TabNine/tabnine-vscode
                                                          name = "tabnine-vscode";
                                                          publisher = "TabNine";
                                                          version = "3.132.0";
                                                          sha256 = "sha256-hwr/lPLOxpraqjyu0MjZd9JxtcruGz7dKA6CVxUZNYw=";
                                                        }

]; })

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
  kdePackages.filelight

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
  mlocate
  pciutils
  authenticator
  translate-shell
  libsForQt5.spectacle

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
  virt-manager
];

##################
#Listing services:
##################
#--> TLP enabling
services.tlp = {
  enable = true;
  settings = {

  USB_AUTOSUSPEND=0;

  CPU_SCALING_GOVERNOR_ON_AC = "performance";
  CPU_SCALING_GOVERNOR_ON_BAT = "balanced";

  CPU_ENERGY_PERF_POLICY_ON_AC = "balance_power";
  CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";

  #CPU_MIN_PERF_ON_AC = 10;
  #CPU_MAX_PERF_ON_AC = 65;

  #CPU_MIN_PERF_ON_BAT = 0;
  #CPU_MAX_PERF_ON_BAT = 75;

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
  programs.kdeconnect = {
    enable = true;
    package = pkgs.kdePackages.kdeconnect-kde;
  };

#--> NoiseTorch
  programs.noisetorch.enable = true;

#--> mlocate // "updatedb & locate"
  services.locate = {
    enable    = true;
    localuser = null;
    package   = pkgs.mlocate;
  };

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

# TODO ---> Nginx
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
        base_url     = "http://localhost/";
        secret_key   = secrets.searx-secret-key;
      };
      ui = {
        default_locale = "en";
        default_theme  = "simple";
      };
      search = {
        safe_search = 0;  # 0: None, 1: Moderate, 2: Strict
        default_lang = "en";
        autocomplete = "duckduckgo";
      };
      engines = [
        { name = "google"; engine = "google"; disabled = false; }
        { name = "wikipedia"; engine = "wikipedia"; disabled = false; }
        { name = "duckduckgo"; engine = "duckduckgo"; disabled = false; }
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

#--> Postgresql SQL DB
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;
    initialScript = ./init_db.sql;
  };

#---> Qbit_torrent x Jackett
  services.jackett = {
    enable = true;
    openFirewall = false;
    dataDir = "/var/lib/jackett";
  };

#---> Enable CUPS to print documents.
  services.printing.enable = true;

#--> Enable sound with pipewire.
  sound.enable = true;
  security.rtkit.enable = true;
  hardware.pulseaudio.enable = false;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

#--> $PATH
environment.localBinInPath = true;

#!###############
#! NixOS Version:
#!###############
  system.stateVersion = "24.05";
}

