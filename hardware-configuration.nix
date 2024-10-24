{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot = {
    #-> Enable NTFS Support for windows files systems
    supportedFilesystems = [ "ntfs" ];

    extraModprobeConfig =''
    options cfg80211 ieee80211_regdom="EG"
    '';

    #? Loader
    loader = {
      timeout = 5;
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      };

    #kernelPackages = pkgs.linuxKernel.packages.linux_6_10;
    extraModulePackages = with config.boot.kernelPackages; [
    acpi_call
    rtl8188eus-aircrack
    #hpuefi-mod
    #tp_smapi
    ];

    kernelModules  = [ "kvm-intel" "uinput" "vfio" "vfio_iommu_type1" "vfio_pci" "vfio_virqfd" ];
    kernelParams   = [ "amdgpu.si_support=1" "amdgpu.cik_support=1" "radeon.si_support=0" "radeon.cik_support=0" "intel_pstate=active" "intel_iommu=on" "iommu=pt" "pci_pm_async=0" "pcie_aspm=force" "i915.enable_dc=2" "i915.enable_fbc=1"];

    initrd = {
    kernelModules = [ "amdgpu" ];
    availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usb_storage" "sd_mod" ];
    };

    consoleLogLevel = 3;

    kernel.sysctl = {
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
};

services.fstrim = {
  enable = true;
  interval = "weekly";
};

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  hardware = {
      firmware = with pkgs; [ wireless-regdb ];
      cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
      enableAllFirmware = true;

      #! Enable bluetooth
      bluetooth = {
        enable = true;
        powerOnBoot = false;
      };


      fancontrol = {
      enable = true;
      config = ''
      INTERVAL=10
      # Corrected paths based on your system
      DEVPATH=hwmon5=devices/platform/coretemp.0 hwmon4=devices/platform/hp-wmi hwmon0=devices/pci0000:00/0000:00:1c.4/0000:03:00.0
      DEVNAME=hwmon5=coretemp hwmon4=hp hwmon0=amdgpu

      # CPU fan control
      FCTEMPS=hwmon4/pwm1=hwmon5/temp1_input
      FCFANS=hwmon4/pwm1=hwmon0/fan1_input

      # Temperature thresholds (in Celsius)
      MINTEMP=hwmon4/pwm1=45
      MAXTEMP=hwmon4/pwm1=85

      # PWM values (0-255)
      MINSTART=hwmon4/pwm1=40
      MINSTOP=hwmon4/pwm1=20
    '';
    };
  };
}