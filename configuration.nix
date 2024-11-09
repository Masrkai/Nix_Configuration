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
    #custom-httrack = pkgs.libsForQt5.callPackage ./Programs/Packages/custom-httrack.nix {};

    #! Bash
    backup = pkgs.callPackage ./Programs/custom/backup.nix {};
    setupcpp = pkgs.callPackage ./Programs/custom/setupcpp.nix {};

    #? Python
    ctj = pkgs.callPackage ./Programs/custom/ctj.nix {};
    MD-PDF = pkgs.callPackage ./Programs/custom/MD-PDF.nix {};

  };

in{
    imports = [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      #./Programs/custom/fan2go.nix
      ./networking.nix
      ./security.nix
      ./bash.nix
    ];

  #! Experimental Features
  nix.settings.experimental-features = [ "nix-command" ];

  systemd.enableEmergencyMode = false;

  #? Set your time zone.
  time.timeZone = "Africa/Cairo";

  i18n={
    #? Select internationalisation properties.
    defaultLocale = "en_US.UTF-8";
      supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "C.UTF-8/UTF-8"
      "ru_RU.UTF-8/UTF-8"
      "ar_EG.UTF-8/UTF-8"
      "de_DE.UTF-8/UTF-8"  # Added German locale
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

  # Enable KDE Plasma 6 Desktop Environment
  services.desktopManager.plasma6 = {
    enable = true;
    enableQt5Integration = false;     #? Qt5 integration is typically not needed for Plasma 6
  };

  # Configure X11 server
  services.xserver = lib.mkForce {
    enable = false;
    xkb.layout = "us";
    xkb.variant = "";
    videoDrivers = [ "intel" "amdgpu" ];
  };

    # Set default session to Wayland
    services.displayManager={
      defaultSession = "plasma";
      sddm = {
        enable = true;
          wayland = {
                enable = true;
                compositor = "kwin";
          };
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
    #? Kate
    libsForQt5.kate
    kdePackages.kate

    #? Kwallet
    libsForQt5.kwallet
    libsForQt5.kwallet-pam
    libsForQt5.kwalletmanager

    kdePackages.kdeconnect-kde
    libsForQt5.qt5.qtvirtualkeyboard
    ];

  #! Enable touchpad support
  services.libinput = {
  enable = true;
  touchpad.disableWhileTyping = false;
    touchpad = {
    accelSpeed = "0.3";
    naturalScrolling = true;
    };
  };

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
    extraGroups = [ "networkmanager" "wheel" "qbittorrent" "jackett" "wireshark" "libvirtd" "kvm" "ubridge" "vboxusers" ];
  };

  # Managing unfree packages
  nixpkgs.config.allowUnfree = true;

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
      noto-fonts-cjk
      noto-fonts-emoji
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
  xterm
  #gparted #!has issues
  glxinfo
  git-lfs
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
    (python311.withPackages (pk: with pk; [
        pip
        nltk
        fire
        lxml
        tqdm
        scapy
        numpy
        pandas
        openai
        pylint
        pyvips
        sqlite
        netaddr
        networkx
        requests
        colorama
        netifaces
        markdown2
        weasyprint
        setuptools
        matplotlib
        markdown-it-py
        python-dotenv


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
  nixd
  alejandra

  direnv
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
    ];
  }
)

#?#############
#? User-Daily:
#?#############
  btop
  kooha
  brave
  yt-dlp
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

  #-> Archivers
  xz
  p7zip
  tarlz

  #-> KDE Specific
  kdePackages.kgamma
  kdePackages.kscreen
  kdePackages.colord-kde
  kdePackages.kscreenlocker
  #kdePackages.qtvirtualkeyboard

  kdePackages.filelight
  kdePackages.plasma-browser-integration

  #Productivity
  gnome.gnome-disk-utility
  thunderbird-bin
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
  powertop
  pciutils
  xorg.xhost
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
  dnsmasq
  tcpdump
  arp-scan
  lighttpd
  ettercap
  bettercap
  traceroute
  aircrack-ng
  linux-wifi-hotspot

#>################
#> Virtualization:
#>################
  qemu_full
  qemu-utils

  virt-viewer
  virt-manager

  spice
  spice-protocol

  win-spice
  win-virtio
];

#>#################
#>Listing services:
#>#################


  #!#################
  #! POWER services:
  #!#################
  powerManagement.resumeCommands = ''
  ${pkgs.kmod}/bin/modprobe -r psmouse
  ${pkgs.kmod}/bin/modprobe psmouse
  '';

  #--> TLP enabling
  services.tlp = lib.mkForce {
    enable = true;
    settings = {
      WOL_DISABLE="Y"; #? disable wake on LAN

      USB_AUTOSUSPEND=1;
      USB_BLACKLIST_WWAN=1;
      USB_BLACKLIST_BTUSB=0;
      USB_BLACKLIST_PHONE=0;

      WIFI_PWR_ON_AC=0;   # no power saving on AC
      WIFI_PWR_ON_BAT=2;  # Aggressive power saving on battery

      #? kernel NMI watchdog timer (0 = disabled/save power, 1=enabled). A value of 1 is relevant for kernel debugging and the watchdog daemon.
      NMI_WATCHDOG=0;

      #? Disable turbo boost on battery
      CPU_BOOST_ON_AC = "0";        # 0 = Disable turbo boost when on AC
      CPU_BOOST_ON_BAT = "0";       # 0 = Disable turbo boost when on battery

      RUNTIME_PM_ON_AC = "on";
      RUNTIME_PM_ON_BAT = "on";

      CPU_MIN_PERF_ON_AC=0;
      CPU_MAX_PERF_ON_AC=80;
      CPU_MIN_PERF_ON_BAT=0;
      CPU_MAX_PERF_ON_BAT=70;

      # CPU_SCALING_GOVERNOR_ON_AC = "conservative";
      # CPU_SCALING_GOVERNOR_ON_BAT = "conservative";

      # CPU_ENERGY_PERF_POLICY_ON_AC = "balance_power";
      # CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";

      #? Restore configured charge thresholds when AC is unplugged
      TPACPI_ENABLE=1;
      NATACPI_ENABLE=1;
      TPSMAPI_ENABLE=1;
      RESTORE_THRESHOLDS_ON_BAT=1;

      #?Seconds laptop mode waits after the disk goes idle before syncing dirty cache blocks from RAM to disk again
      DISK_IDLE_SECS_ON_AC=0;
      DISK_IDLE_SECS_ON_BAT=2;

      #? Timeout (in seconds) for writing unsaved/dirty data in file system buffers to disk.
      MAX_LOST_WORK_SECS_ON_AC=15;
      MAX_LOST_WORK_SECS_ON_BAT=60;

      #? Runtime Power Management for AHCI controllers and disks:
      AHCI_RUNTIME_PM_ON_AC="on";
      AHCI_RUNTIME_PM_ON_BAT="on";

      #? Seconds of inactivity before disk/controller is suspended
      AHCI_RUNTIME_PM_TIMEOUT=15;

      #? PCI Express Active State Power Management (PCIe ASPM):
      #   default, performance, powersave
      PCIE_ASPM_ON_AC="performance";
      PCIE_ASPM_ON_BAT="powersave";

      #? Enable audio power saving for Intel HDA, AC97 devices (timeout in secs).
      # A value of 0 disables, >=1 enables power saving.
      SOUND_POWER_SAVE_ON_AC=0;
      SOUND_POWER_SAVE_ON_BAT=1;

      # Power off optical drive in UltraBay/MediaBay: 0=disable, 1=enable.
      # Drive can be powered on again by releasing (and reinserting) the eject lever
      # or by pressing the disc eject button on newer models.
      # Note: an UltraBay/MediaBay hard disk is never powered off.
      BAY_POWEROFF_ON_AC=0;
      BAY_POWEROFF_ON_BAT=1;

      RUNTIME_PM_ALL = "1";                # Enable runtime power management for all PCI(e) bus devices
      RUNTIME_PM_DRIVER_BLACKLIST="amdgpu nouveau nvidia radeon iwlwifi ";
      #RUNTIME_PM_BLACKLIST = "i2c_adapter:i2c-12 i2c_adapter:i2c-3 i2c_adapter:i2c-10 i2c_adapter:i2c-1 i2c_adapter:i2c-8 i2c_adapter:i2c-0 i2c_adapter:i2c-6 i2c_adapter:i2c-11 i2c_adapter:i2c-4 i2c_adapter:i2c-2 i2c_adapter:i2c-9 i2c_adapter:i2c-7 i2c_adapter:i2c-5 pci:v00008086d000015b8 pci:v00008086d00001575 pci:v00008086d000015b5 pci:v00008086d000015b1 pci:v00008086d000015b3 pci:v00008086d000015c8 pci:v00008086d00001903 pci:v00008086d0000156b pci:v00001002d00006821";

      ETHERNET_WOL_DISABLE = "Y";                         # Disable Wake-on-LAN
      DEVICES_TO_DISABLE_ON_BAT = "ethernet";             # Disable ethernet on battery if you don't need it
      DEVICES_TO_DISABLE_ON_BAT_NOT_IN_USE = "ethernet";  # Disable when not in use on battery
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

  #--> Qemu KVM & VirtualBox
    virtualisation = lib.mkForce {

    # Enable VirtualBox kernel modules
    virtualbox.host.enable = true;
    # Optionally, enable the VirtualBox extension pack (for USB 2.0/3.0 support, etc.)
    virtualbox.host.enableExtensionPack = true;

    spiceUSBRedirection.enable = true;
      libvirtd = {
        enable = true;
        allowedBridges = [ "virbr0"];
        qemu = {
          package = pkgs.qemu_full;
          runAsRoot = true;
          swtpm.enable = true;

          ovmf = {
            enable = true;
            packages = [(pkgs.OVMFFull.override {
            secureBoot = true;
            tpmSupport = true;
          }).fd];
          };
        };
      };
    };
    services.spice-vdagentd.enable = false;
    programs.virt-manager.enable   = true;
    programs.dconf.enable = true;


  # Ensure USB storage is not automatically mounted
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTRS{idVendor}=="04e8", ATTRS{idProduct}=="6860", ENV{UDISKS_AUTO}="0"
  '';

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
    };
  };
};

  #---> SearXNG
  services.searx = {
  enable = true;
  package = pkgs.searxng;  # Ensure you're using the correct package
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
          # Add these lines to ensure Searx uses Stubby for DNS
          dns_resolver = {
            enable = true;
            use_system_resolver = false;  # Disable system resolver
            resolver_address = "127.0.0.1:53";  # Point to Stubby
          };
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

      # Initial zoom level (optional)
      initial_zoom_level 0.75
    '';

#!###############
#! NixOS Version:
#!###############
  system.stateVersion = "24.05";
}

