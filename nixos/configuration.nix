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
  nil
  git
  file
  unzip
  xterm
  gparted
  searxng
  git-lfs
  thermald
  rustdesk-flutter

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
  programs.kdeconnect.enable = true;

#--> NoiseTorch
  programs.noisetorch.enable = true;

#--> mlocate // "updatedb & locate"
  services.locate.localuser = null;
  services.locate.enable    = true;
  services.locate.package   = pkgs.mlocate;

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

#--> $PATH
environment.localBinInPath = true;

#--> $BASH
programs.bash = {
  enableLsColors = true;
  enableCompletion = true;
  promptInit = '' PS1='\[\e[36;1m\]>>>>>>Hi Masrkai!\[\e[0m\] \[\e[1m\]\w\n\[\e[38;5;160m\]\t\[\e[39m\][\[\e[36m\]\u\[\e[38;5;240m\]_\[\e[38;5;208m\]\H\[\e[39m\]]\$\[\e[0m\] ' '';
  interactiveShellInit =  /* bash */ ''

    #bash configuration
      if [ -f /etc/profile ]; then
        . /etc/profile
      fi

      if [ -f ~/.bashrc ]; then
        . ~/.bashrc
      fi
  '';

  shellInit =
  /* bash */
  ''
    # If not running interactively, don't do anything
    [[ $- != *i* ]] && return

    PS1='\[\e[36;1m\]>>>>>>Hi Masrkai!\[\e[0m\] \[\e[1m\]\w\n\[\e[38;5;160m\]\t\[\e[39m\][\[\e[36m\]\u\[\e[38;5;240m\]_\[\e[38;5;208m\]\H\[\e[39m\]]\$\[\e[0m\] '

    #--Functions
    wh() {
        sudo pkill dnsmasq ; cd $HOME/Programs/airgeddon && sudo bash airgeddon.sh ; cd
    }
    scode(){
        sudo codium --no-sandbox --user-data-dir=/home/masrkai/.config/VSCodium
    }
    switch(){
        sudo nixos-rebuild switch
    }
    garbage(){
        nix-collect-garbage -d && nix-store --optimise && pip cache purge
    }
    gens(){
        sudo nix-env --list-generations --profile /nix/var/nix/profiles/system &&  echo "to remove Gens type:  sudo nix-env --profile /nix/var/nix/profiles/system --delete-generations <Gen's-Numbers>"
    }
    update(){
       sudo nix-channel --update && sudo nixos-rebuild switch --upgrade
    }
    sudophone(){
        adb shell sh /sdcard/Android/data/moe.shizuku.privileged.api/start.sh
    }
    fixcode(){
        rm -rf ~/.config/VSCodium/GPUCache/
    }
    fixbrave(){
        sudo rm -rf ~/.config/BraveSoftware/Brave-Browser/SingletonLock
    }
    wl(){
         sudo python3 /home/masrkai/Programs/Better-Evil-Limiter/evillimiter/evillimiter.py -f
    }
    fusb(){
         sudo chown masrkai  /dev/ttyUSB0
    }
    setupcpp(){
        /home/masrkai/Programs/Bash_Scripts/setup_cpp.sh
    }
    backup(){
       /home/masrkai/Programs/Bash_Scripts/Backup.sh
    }

    #! Extraction function
    function extract {
     if [ $# -eq 0 ]; then
        echo "Usage: extract <path/file_name>.<zip|rar|bz2|gz|tar|tbz2|tgz|Z|7z|xz|ex|tar.bz2|tar.gz|tar.xz|.zlib|.cso|.zst>"
        echo "       extract <path/file_name_1.ext> [path/file_name_2.ext] [path/file_name_3.ext]"
     fi
        for n in "$@"; do
            if [ ! -f "$n" ]; then
                echo "'$n' - file doesn't exist"
                return 1
            fi

            case "''${n%,}" in
              *.cbt|*.tar.bz2|*.tar.gz|*.tar.xz|*.tbz2|*.tgz|*.txz|*.tar)
                           tar zxvf "$n"       ;;
              *.lzma)      unlzma ./"$n"      ;;
              *.bz2)       bunzip2 ./"$n"     ;;
              *.cbr|*.rar) unrar x -ad ./"$n" ;;
              *.gz)        gunzip ./"$n"      ;;
              *.cbz|*.epub|*.zip) unzip ./"$n"   ;;
              *.z)         uncompress ./"$n"  ;;
              *.7z|*.apk|*.arj|*.cab|*.cb7|*.chm|*.deb|*.iso|*.lzh|*.msi|*.pkg|*.rpm|*.udf|*.wim|*.xar|*.vhd)
                           7z x ./"$n"        ;;
              *.xz)        unxz ./"$n"        ;;
              *.exe)       cabextract ./"$n"  ;;
              *.cpio)      cpio -id < ./"$n"  ;;
              *.cba|*.ace) unace x ./"$n"     ;;
              *.zpaq)      zpaq x ./"$n"      ;;
              *.arc)       arc e ./"$n"       ;;
              *.cso)       ciso 0 ./"$n" ./"$n.iso" && \
                                extract "$n.iso" && \rm -f "$n" ;;
              *.zlib)      zlib-flate -uncompress < ./"$n" > ./"$n.tmp" && \
                                mv ./"$n.tmp" ./"''${n%.*zlib}" && rm -f "$n"   ;;
              *.dmg)
                          hdiutil mount ./"$n" -mountpoint "./$n.mounted" ;;
              *.tar.zst)  tar -I zstd -xvf ./"$n"  ;;
              *.zst)      zstd -d ./"$n"  ;;
              *)
                          echo "extract: '$n' - unknown archive method"
                          return 1
                          ;;
            esac
        done
    }
  '';
  shellAliases = {
    cl = "clear";
    cp = "cp -vi";
    mv = "mv -vi";
    sudo = "sudo ";
    code = "codium";
    ff = "fastfetch";
    ip = "ip --color=auto";
    grep = "grep --color=auto";
    anime = "ani-cli -q 720 --dub";
    cpv = "rsync -avh --info=progress2";
    ascr = "scrcpy --no-audio -Sw --no-downsize-on-error";
    ls = "eza --color=always --long --git --icons=always";
    l = "eza  --color=always --long --tree --git --links -a --icons=always";
  };
};

#!###############
#! NixOS Version:
#!###############
  system.stateVersion = "24.05";
}

