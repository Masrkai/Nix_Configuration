
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot = {
    #-> Enable NTFS Support for windows files systems
    supportedFilesystems = [ "ntfs" ];

    # extraModprobeConfig =''
    # options cfg80211 ieee80211_regdom="EG"
    # '';

    #? Loader
    loader = {
      timeout = 5;
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      };

    kernelPackages = pkgs.linuxPackages_latest;
    extraModulePackages = with config.boot.kernelPackages; [
    #rtl8188eus-aircrack
    #acpi_call
    #hpuefi-mod
    #tp_smapi
    ];

    kernelModules = [
    "kvm-intel" "uinput" "vfio" "vfio_iommu_type1" "vfio_pci" "hp_wmi" "drivetemp"
    "cpufreq_ondemand" "cpufreq_conservative"   # CPU governors
    "acpi-cpufreq"                              # Enable ACPI CPU frequency driver
    ];

    #! Kernel parameters
    kernelParams = [
    "amdgpu.si_support=1" "amdgpu.cik_support=1"                # AMD GPU driver
    "radeon.si_support=0" "radeon.cik_support=0"                # Disable Radeon GPU
    "intel_pstate=disable"                                      # Disable Intel P-state driver to use acpi-cpufreq
    "intel_iommu=on" "iommu=pt"                                 # Intel IOMMU settings
    "pci_pm_async=0" "pcie_aspm=force"                          # Power management
    "usbcore.autosuspend=1"                                     # Enable USB autosuspend for power savings
    ];

  #! Initial RAM disk configuration
  initrd = {
    kernelModules = [ "amdgpu" ];
    availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usb_storage" "sd_mod" ];
  };

    consoleLogLevel = 3;

    kernel.sysctl = {
      "vm.laptop_mode" = 1;                             # Enable Laptop mode for disk spindown
      "kernel.nmi_watchdog" = 0;                        # Disable NMI watchdog for power saving
      "vm.dirty_writeback_centisecs" = 1500;
      "vm.dirty_expire_centisecs" = 3000;
    };

  };

  fileSystems."/" = {
  device = "/dev/disk/by-uuid/c2973410-4dd5-4c19-a859-e2e1db7ec9b2";
  fsType = "btrfs";
  options = [
    "subvol=@"
    "noatime"
    "nodiratime"
    "discard=async"     # Instead of just "discard"
    "space_cache=v2"    # Better space cache
    "compress=zstd:1"   # Efficient compression
    "ssd"               # Optimize for SSD
    "autodefrag"        # Automatic defragmentation
  ];
};


fileSystems."/boot" =
{ device = "/dev/disk/by-uuid/45FF-32D8";
  fsType = "vfat";
  options = [  "rw" ];
};

services.fstrim = {
  enable = true;
  interval = "weekly";
};

  swapDevices = [ ];
  zramSwap.enable = false;  # Also disable zram swap

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  hardware = {
      #firmware = with pkgs; [ wireless-regdb ];
      cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
      enableAllFirmware = true;

      #! Enable bluetooth
      bluetooth = {
        enable = true;
        powerOnBoot = false;
      };
   };
   services.blueman.enable = false;  # Disable Blueman

}
