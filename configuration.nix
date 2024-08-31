{ config, lib, pkgs, ... }:

let
  unstable = import <unstable> {config.allowUnfree = true;};
  secrets = import ./secrets.nix;

  #! Bash
  backup = pkgs.callPackage ./Programs/backup.nix {};
  setupcpp = pkgs.callPackage ./Programs/setupcpp.nix {};

  #? Python
  ctj = pkgs.callPackage ./Programs/ctj.nix {};

in {
    imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./networking.nix
      ./security.nix
      ./bash.nix
    ];

  #Experimental Features
  nix.settings.experimental-features = [ "nix-command" ];


  # Bootloader.
 boot.loader = {
  timeout = 5;
  systemd-boot.enable = true;
  efi.canTouchEfiVariables = true;
};

  #-> Enable NTFS Support for windows files systems
  boot.supportedFilesystems = [ "ntfs" ];

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


  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    #theme = "KDE Plasma 5";
  };

  #! Enable the KDE Plasma Desktop Environment.
  services.desktopManager = {
    plasma6.enable = true;
    plasma6.enableQt5Integration = false ;
  };

  #! What to not install on KDE
  environment.plasma6.excludePackages = with pkgs; [
    kdePackages.kate
    libsForQt5.kwallet
    libsForQt5.kwallet-pam
    libsForQt5.kwalletmanager
    ];

  #! Configure keymap in X11
  services.xserver = {
    enable = false;
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

  #! GPU drivers and Vulkan support
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      mesa
      libva
      amdvlk
      vaapiIntel
      vulkan-tools
      vulkan-loader
      intel-media-driver
      rocm-opencl-icd
      rocm-opencl-runtime
    ];
  };

  #? Add Vulkan ICDs
  environment.variables = {
  AMD_VULKAN_ICD = "RADV";
  VULKAN_ICD_FILENAMES = "${pkgs.amdvlk}/share/vulkan/icd.d/amd_icd64.json:${pkgs.intel-compute-runtime}/share/vulkan/icd.d/intel_icd.x86_64.json";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.masrkai = {
    isNormalUser = true;
    description = "Masrkai";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" ];
  };

  # Managing unfree packages
  nixpkgs.config = {
    allowUnfree = true;
  };

  #! Diable flatpack
  services.flatpak.enable = lib.mkForce false;

  #-> Fonts
  fonts.packages = with pkgs; [
    #* First Class
    iosevka-bin
    material-design-icons

    #> Second Class
    noto-fonts
    dejavu_fonts
    noto-fonts-cjk
    liberation_ttf
  ];


environment.systemPackages = with pkgs; [

#*############
#*Development:
#*############
  #-> Custom
  ctj
  backup
  setupcpp

  searxng
  hw-probe

  #-> General
  bat
  eza
  nil
  git
  kitty
  unzip
  xterm
  gparted
  glxinfo
  git-lfs
  thermald
  efibootmgr
  bash-completion
  rustdesk-flutter

  #-> Engineering
  #kicad
  #freecad

  #-> Phone
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
      pyvips
      sqlite
      netaddr
      requests
      colorama
      netifaces
      setuptools
      matplotlib

      #-> Juniper/jupter
      notebook
      jupyterlab

      ipykernel
      ipython-sql
      ipython-genutils


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
  cmake
  gnumake
  clang-tools
  (hiPrio gcc)
  (lowPrio clang)

  #-> Rust #Rust is a very special case and it's packaged by default in Nix DW about it

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

                            #* Bash
                            mads-hartmann.bash-ide-vscode

                            #* Markdown
                            bierner.markdown-mermaid

                            #* Yamal
                            redhat.vscode-yaml

                            #* General
                            usernamehw.errorlens
                            mechatroner.rainbow-csv      #> For DataBases .csv files!
                            donjayamanne.githistory      #> GIT History
                            grapecity.gc-excelviewer     #>  For Exel Files
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
                                                        {
                                                          #https://open-vsx.org/extension/TabNine/tabnine-vscode
                                                          name = "tabnine-vscode";
                                                          publisher = "TabNine";
                                                          version = "3.132.0";
                                                          hash = "sha256-hwr/lPLOxpraqjyu0MjZd9JxtcruGz7dKA6CVxUZNYw=";
                                                        }
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

]; })

#?#############
#? User-Daily:
#?#############
  btop
  kooha
  brave
  clamtk
  haruna
  jackett
  ani-cli
  fastfetch
  syncthing
  noisetorch
  qbittorrent
  authenticator
  signal-desktop
  nix-output-monitor
  kdePackages.filelight

  #Productivity
  anytype
  betterbird
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
  translate-shell

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


  environment.etc."xdg/kitty/kitty.conf".text = ''
    # Basic settings
    font_family Iosevka Fixed Hv Ex Obl
    font_size 11
    adjust_line_height 0
    adjust_column_width 0
    disable_ligatures never

    # Use additional symbols from Material Design Icons
    symbol_map U+E000-U+E7C5 MaterialDesignIcons

    # Color scheme
    background #000000
    foreground #ffffff
    cursor #93a1a1

    # Window layout
    remember_window_size no
    initial_window_width 157c
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

    # Extra configuration (for extensibility)
    # Add any additional configuration here
  '';

#--> $PATH
environment.localBinInPath = true;

#!###############
#! NixOS Version:
#!###############
  system.stateVersion = "24.05";
}

