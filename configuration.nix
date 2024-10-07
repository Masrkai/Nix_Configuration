{ config, lib, pkgs, ... }:

let
  #unstable = import <unstable> {config.allowUnfree = true;};
  secrets = import ./Sec/secrets.nix;

  customPackages = {
    #? .Nix
    airgeddon = pkgs.callPackage ./Programs/Packages/airgeddon.nix {};
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

  };

in{
    imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./networking.nix
      ./security.nix
      ./bash.nix
    ];

  #! Experimental Features
  nix.settings.experimental-features = [ "nix-command" ];

  #? Set your time zone.
  time.timeZone = "Africa/Cairo";

  i18n={
    #? Select internationalisation properties.
    defaultLocale = "en_US.UTF-8";

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

  # Enable KDE Plasma 6 Desktop Environment
  services.desktopManager.plasma6 = {
    enable = true;
    # Qt5 integration is typically not needed for Plasma 6
    enableQt5Integration = false;
  };

  # Configure X11 server (needed for some Wayland compositors)
  services.xserver = {
    enable = false;  # This should be true even for Wayland
    xkb.layout = "us";
    xkb.variant = "";
    videoDrivers = [ "intel" "amdgpu" ];
  };


  # Set default session to Wayland
  services.displayManager={
    defaultSession = "plasma";
    sddm = {
    enable = true;
    wayland.enable = true;
    };
  };
  # Enable Wayland-specific services
  programs.xwayland.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      kdePackages.xdg-desktop-portal-kde
    ];
  };

  #! What to not install on KDE
  environment.plasma6.excludePackages = with pkgs; [
    kdePackages.kate
    libsForQt5.kwallet
    libsForQt5.kwallet-pam
    libsForQt5.kwalletmanager
    kdePackages.kdeconnect-kde
    ];

  #! Enable touchpad support
  services.libinput.enable = true;

  #? Weylus
  programs.weylus = {
    enable = true;
    openFirewall = true;
  };

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
      vkd3d
      libva
      amdvlk
      dxvk_2
      vaapiIntel
      vulkan-tools
      vulkan-loader
      intel-media-driver
      rocm-opencl-icd
      rocm-opencl-runtime
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


      #? Add Vulkan ICDs for Graphics
      AMD_VULKAN_ICD = "RADV";
      VULKAN_ICD_FILENAMES = "${pkgs.amdvlk}/share/vulkan/icd.d/amd_icd64.json:${pkgs.intel-compute-runtime}/share/vulkan/icd.d/intel_icd.x86_64.json";
    };

    # Set environment variables for Wayland
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
      XDG_SESSION_TYPE = "wayland";
      XDG_RUNTIME_DIR = "/run/user/$UID";

      #QT_QPA_PLATFORM = "wayland";
      GDK_BACKEND = "wayland";
      WLR_NO_HARDWARE_CURSORS = "1";
    };
   localBinInPath = true;
  };

  programs.less = {
    enable = true;
    envVariables = {
      LESS = "-R --use-color -Dd+r$Du+b";
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.masrkai = {
    isNormalUser = true;
    description = "Masrkai";
    extraGroups = [ "networkmanager" "wheel" "qbittorrent" "jackett" "wireshark" "libvirtd" "kvm" "ubridge" ];
  };

  # Managing unfree packages
  nixpkgs.config.allowUnfree = true;

  #! Diable flatpack
  services.flatpak.enable = lib.mkForce false;

  #-> Fonts
  fonts = {
  packages = with pkgs; [

    #* First Class
    iosevka-bin
    material-design-icons

      #> Second Class
      noto-fonts
      dejavu_fonts
      noto-fonts-cjk
      liberation_ttf
      ];

        fontconfig.defaultFonts.emoji = [
        "Noto Color Emoji"
        ];
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
  customPackages.airgeddon
  customPackages.wifi-honey
  customPackages.hostapd-wpe
  customPackages.logisim-evolution
  customPackages.super-productivity

  searxng
  nixos-generators

  #-> General
    #-! GNS3 Specific Bullshit
    gns3-gui
    gns3-server
    dynamips
    vpcs
    ubridge

  bat
  eza
  git
  less
  most
  kitty
  unzip
  xterm
  weylus
  gparted
  glxinfo
  git-lfs
  hw-probe
  thermald
  efibootmgr
  rustdesk-flutter
  (lowPrio bash-completion)

  (hiPrio nvtopPackages.amd)
  (lowPrio nvtopPackages.intel)

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
      fire
      lxml
      tqdm
      scapy
      numpy
      pandas
      pylint
      pyvips
      sqlite
      netaddr
      requests
      colorama
      netifaces
      markdown2
      weasyprint
      setuptools
      matplotlib

      #-> Juniper/jupter
      notebook
      jupyterlab

      ipykernel
      ipython-sql
      ipython-genutils

      beautifulsoup4
      terminaltables
      huggingface-hub
      types-beautifulsoup4
      pyinstaller-versionfile
      ]
    )
  )

  #-> C++
  #? Builders
  cmake
  gnumake
  cppcheck
  pkg-config

  #? Libraries
  eigen
  nlohmann_json

  boost185.dev
  (hiPrio boost185)

  #! Compilers + Extras
  gdb
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
  nil
  direnv
  nix-direnv
  nix-output-monitor

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
                            ms-vscode.live-server

                            #* Bash
                            mads-hartmann.bash-ide-vscode

                            #* Markdown
                            bierner.markdown-mermaid

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
                                                        # {
                                                        #   name = "cpptools";
                                                        #   publisher = "ms-vscode";
                                                        #   version = "1.22.2";  # Check for the latest version
                                                        #   hash = "sha256-ek4WBr9ZJ87TXlKQowA68YNt3WNOXymLcVfz1g+Be2o=";
                                                        # }
                                                        {
                                                          #https://marketplace.visualstudio.com/items?itemName=ms-python.pylint
                                                          name = "pylint";
                                                          publisher = "ms-python";
                                                          version = "2023.11.13481007";  # Check for the latest version
                                                          hash = "sha256-rn+6vT1ZNpjzHwIy6ACkWVvQVCEUWG2abCoirkkpJts=";
                                                        }
                                                        {
                                                          #https://marketplace.visualstudio.com/items?itemName=cweijan.vscode-office
                                                          name = "vscode-office";
                                                          publisher = "cweijan";
                                                          version = "3.4.1";  # Check for the latest version
                                                          hash = "sha256-UNjU+DEeq8aoJuTOWpPg1WAUBwGpxdOrnsMBW7xddzw=";
                                                        }
    ];
  }
)

#?#############
#? User-Daily:
#?#############
  btop
  kooha
  p7zip
  brave
  haruna
  jackett
  ani-cli
  fastfetch
  syncthing
  noisetorch
  qbittorrent
  authenticator
  mission-center
  signal-desktop


  #-> KDE Specific
  kdePackages.kgamma
  kdePackages.kscreen
  kdePackages.colord-kde
  kdePackages.kscreenlocker

  kdePackages.filelight
  kdePackages.plasma-browser-integration

  #Productivity
  betterbird
  libreoffice-qt
  gimp-with-plugins

  #Gaming
  heroic
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
  hping
  getdns
  crunch
  asleap
  openssl
  linssid
  dnsmasq
  tcpdump
  lighttpd
  ettercap
  bettercap
  traceroute
  aircrack-ng
  linux-wifi-hotspot

#>################
#> Virtualization:
#>################
  qemu
  virt-manager
];

#>#################
#>Listing services:
#>#################


  #!#################
  #! POWER services:
  #!#################

  #--> TLP enabling
  services.tlp = lib.mkForce {
    enable = true;
    settings = {

    USB_AUTOSUSPEND=0;

    # Disable turbo boost on battery
    CPU_BOOST_ON_BAT = "0";       # 0 = Disable turbo boost when on battery
    CPU_BOOST_ON_AC = "1";        # 1 = Enable turbo boost when on AC

    RUNTIME_PM_ON_BAT = "on";
    RUNTIME_PM_ON_AC = "on";

    CPU_SCALING_GOVERNOR_ON_AC = "performance";
    CPU_SCALING_GOVERNOR_ON_BAT = "balanced";

    CPU_ENERGY_PERF_POLICY_ON_AC = "balance_power";
    CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";

    #! Optional helps save long term battery health
    START_CHARGE_THRESH_BAT0 = 80;
    STOP_CHARGE_THRESH_BAT0 = 100;
    };
  };

  #--> Enable thermald (only necessary if on Intel CPUs)
    services.thermald.enable = true;

  #--> Disabled Power-Profiles for TLP to take action.
    services.power-profiles-daemon.enable = false;

  #--> Better scheduling for CPU cycles
    services.system76-scheduler.settings.cfsProfiles.enable = true;

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
  services.syncthing = {
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
    };
      folders = {
        "College_shit" = {
          path = "~/Documents/College/Current/";
          devices = [ "A71" "Tablet" ];
        };
        "Forbidden_Knowledge" = {
          path = "~/Documents/Books/";
          devices = [ "A71" ];
        };
    };
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
          max_request_timeout = 8.0;
        };
        cache = {
          cache_dir = "/var/cache/searx";
        };
      };
    };

  #---> Colord
  services.colord.enable = true;

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

      #->Kitty terminal
      environment.etc."xdg/kitty/kitty.conf".text = ''
      # Basic settings
      font_family Iosevka Fixed Hv Ex Obl
      font_size 13

      # Adjust this value as needed
      modify_font cell_height 90%
      adjust_column_width 0
      disable_ligatures never

      # Scroll settings
      scrollback_lines 10000
      mouse_wheel_scroll yes

      # Use additional symbols from Material Design Icons
      symbol_map U+E000-U+E7C5 Material Design Icons

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

      # Initial zoom level (optional)
      initial_zoom_level 0.75
    '';

#!###############
#! NixOS Version:
#!###############
  system.stateVersion = "24.05";
}

