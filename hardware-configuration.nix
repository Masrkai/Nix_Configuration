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

    # kernelPackages = pkgs.linuxPackages_latest;
    extraModulePackages = with config.boot.kernelPackages; [
    #rtl8188eus-aircrack
    #acpi_call
    #hpuefi-mod
    #tp_smapi
    ];

    kernelModules = [
    "kvm-intel" "uinput" "vfio" "vfio_iommu_type1" "vfio_pci" "vfio_virqfd" "hp_wmi" "drivetemp"
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
      "vm.dirty_writeback_centisecs" = 1500;
      "vm.dirty_expire_centisecs" = 3000;
      "vm.laptop_mode" = 5;                             # Enable Laptop mode for disk spindown
      "kernel.nmi_watchdog" = 0;                        # Disable NMI watchdog for power saving
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
      #firmware = with pkgs; [ wireless-regdb ];
      cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
      enableAllFirmware = true;

      #! Enable bluetooth
      bluetooth = {
        enable = true;
        powerOnBoot = false;
      };

    sensor.iio.enable = true;
    sensor.hddtemp.enable =true;
    sensor.hddtemp.drives = ["/dev/sda"];

    fancontrol = {
      enable = false;
      config =
      ''
      INTERVAL=5  # Polling interval in seconds

      # Define path to the fan control and CPU temperature sensor
      DEVPATH=/dev/hwmon_coretemp
      DEVNAME=coretemp

      # Map PWM control to CPU temperature
      FCTEMPS=/dev/hwmon_coretemp/pwm1=/dev/hwmon_coretemp/temp1_input
      FCFANS=/dev/hwmon_coretemp/pwm1=/dev/hwmon_coretemp/fan1_input

      # Set temperature thresholds and fan speed
      MINTEMP=/dev/hwmon_coretemp/pwm1=45  # Fan off below 45°C
      MAXTEMP=/dev/hwmon_coretemp/pwm1=85  # Full speed at 85°C
      MINSTART=/dev/hwmon_coretemp/pwm1=50 # Minimum PWM speed to start the fan
      MINSTOP=/dev/hwmon_coretemp/pwm1=30  # PWM speed to stop the fan
      '';
    };
  };

  # #! For persistant Sensors names
  services.udev.enable = true;
  services.udev.extraRules = lib.mkForce ''
    # Persistent names for hwmon devices
    SUBSYSTEM=="hwmon", ATTR{name}=="amdgpu", SYMLINK+="hwmon_amdgpu"
    SUBSYSTEM=="hwmon", ATTR{name}=="hp", SYMLINK+="hwmon_hp"
    SUBSYSTEM=="hwmon", ATTR{name}=="coretemp", SYMLINK+="hwmon_coretemp"
    SUBSYSTEM=="hwmon", ATTR{name}=="acpitz", SYMLINK+="hwmon_acpitz"
  '';

}