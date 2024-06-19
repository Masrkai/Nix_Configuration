{ config, pkgs, ... }:

let
  unstable = import <unstable> {config.allowUnfree = true;};
in{
    imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

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
    enable = true;
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

#########################
#Networking-Configration:
#########################
  networking.hostName = "NixOS"; # Defining hostname.
  networking.networkmanager.enable = true;
  networking.usePredictableInterfaceNames = false ;

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 443 8384 22000 /*#Syncthing */  ];
  networking.firewall.allowedUDPPorts = [ 443 22000 21027 /*#Syncthing */ ];


  # Configure network proxy if necessary
  #networking.proxy.default = "https://88.198.212.86:3128/";
  #networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";


#####################
#AMD-Legacy-Graphics:
#####################

  # GPU drivers and Vulkan support
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;

    extraPackages = [
      pkgs.mesa
      pkgs.vaapiIntel
      pkgs.vulkan-loader
      pkgs.vulkan-tools
      pkgs.libva ]; };

  # Add Vulkan ICDs
  environment.variables.AMD_VULKAN_ICD = "RADV";
  environment.variables.VULKAN_ICD_FILENAMES = "${pkgs.vulkan-loader}/share/vulkan/icd.d/radeon_icd.x86_64.json:${pkgs.vulkan-loader}/share/vulkan/icd.d/intel_icd.x86_64.json"; #MASRKAI
#########################################################################################################################################################################################



  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.masrkai = {
    isNormalUser = true;
    description = "Masrkai";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" ];
    packages = with pkgs; [
  ];
};

# Allow unfree packages & Flatpak
services.flatpak.enable = true;

nixpkgs.config = {
  allowUnfree = true;
};

#-> Fonts
fonts.packages = with pkgs; [
  fira-code
  dina-font
  noto-fonts
  proggyfonts
  liberation_ttf
  noto-fonts-cjk
  noto-fonts-emoji
  fira-code-symbols
  mplus-outline-fonts.githubRelease
];


environment.systemPackages = with pkgs; [
#############
#Development:
#############
  #->General
  git
  file
  gnumake
  vscodium
  gnu-config
  swiftPackages.stdenv
  updateAutotoolsGnuConfigScriptsHook

  #->Phone
  scrcpy
  android-tools

  #-> Python
  python311Full
  python311Packages.pip
  python311Packages.pipx
  python311Packages.tqdm
  python311Packages.scapy
  python311Packages.netaddr
  python311Packages.colorama
  python311Packages.netifaces
  python311Packages.setuptools
  python311Packages.terminaltables

  #-> C++
  gcc
  cmake
  clang
  clang-tools

  #-> Rust #Rust is a very special case and it's packaged by default in Nix DW about it
  rustup


  #-> MicroChips
  esptool
  usbutils
  esptool-ck
  arduino-ide
  arduino-core

############
#User-Daily:
############
  btop
  brave
  haruna
  fastfetch
  syncthing
  noisetorch
  betterbird
  qbittorrent
  signal-desktop
  telegram-desktop
  unstable.ani-cli
  libsForQt5.kdeconnect-kde

  #Productivity
  anytype
  libreoffice-qt
  gimp-with-plugins

  #Gaming
  dxvk
  mesa
  heroic
  lutris
  winetricks
  protonup-qt
  wineWowPackages.full

  #Games
  mindustry-wayland

  #System
  tlp
  mlocate
  pciutils
  libsForQt5.spectacle
  libsForQt5.plasma-integration

  #Spell_check
  aspell
  aspellDicts.en
  aspellDicts.en-computers
  aspellDicts.en-science

####################
#Pentration-Testing:
####################
  iw
  mdk4
  john
  bully
  tshark
  crunch
  asleap
  openssl
  linssid
  dnsmasq
  tcpdump
  hashcat
  hcxtools
  lighttpd
  pixiewps
  ettercap
  bettercap
  wireshark
  hcxdumptool
  aircrack-ng
  hashcat-utils
  reaverwps-t6x
  linux-wifi-hotspot

################
#Virtualization:
################
  qemu
  qemu-utils
  virt-manager

  (vscode-with-extensions.override {
    vscode = vscodium;
    vscodeExtensions = with vscode-extensions; [
      bbenoist.nix
      ms-vscode-remote.remote-ssh]
      ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {name = "remote-ssh-edit";
        publisher = "ms-vscode-remote";
        version = "0.47.2";
        sha256 = "1hp6gjh4xp2m1xlm1jsdzxw9d8frkiidhph6nvl24d0h8z34w49g"; } ];
  }) ];

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

  CPU_SCALING_GOVERNOR_ON_AC = "balanced";
  CPU_SCALING_GOVERNOR_ON_BAT = "balanced";

  CPU_ENERGY_PERF_POLICY_ON_AC = "balance_power";
  CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";

  CPU_MIN_PERF_ON_AC = 0;
  CPU_MAX_PERF_ON_AC = 75;

  CPU_MIN_PERF_ON_BAT = 0;
  CPU_MAX_PERF_ON_BAT = 75;

  CPU_BOOST_ON_AC=0;
  CPU_BOOST_ON_BAT=0;

  CPU_HWP_DYN_BOOST_ON_AC=0;
  CPU_HWP_DYN_BOOST_ON_BAT=0;

  #Optional helps save long term battery health
  START_CHARGE_THRESH_BAT0 = 95; # 95 and bellow it starts to charge
  STOP_CHARGE_THRESH_BAT0 = 100; # 100 and above it stops charging
  };
};

#--> Disabled Power-Profiles for TLP to take action.
  services.power-profiles-daemon.enable = false;

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

#--> Enabling Dconf
programs.dconf.enable = true;

#--> $PATH
environment.localBinInPath = true;

################
# NixOS Version:
################
  system.stateVersion = "24.05";
}
