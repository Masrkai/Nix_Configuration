
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
      #(modulesPath + "/installer/scan/not-detected.nix")
    ];

    #services.systemd-oomd.enable = true;

    systemd.oomd = {
    enable = true;                        # Enable systemd-oomd

    enableRootSlice = true;               # Manage memory pressure for root processes
    enableSystemSlice = true;             # Monitor and manage system services to avoid OOM issues
    enableUserSlices = true;              # Manage memory for user sessions, reducing per-user memory pressure

    # Additional configuration to fine-tune `systemd-oomd` behavior
    # extraConfig = ''
    #   MemoryPressureDurationSec=1min      # Minimum time memory pressure should exist before triggering
    #   SwapUsedLimitPercent=80             # Trigger when swap usage exceeds 80% to avoid heavy swapping
    #   DefaultMemoryPressureThresholdPercent=60  # Start reclaiming memory when usage reaches 60%
    #   '';
    };


  boot = {
    #-> Enable NTFS Support for windows files systems
    supportedFilesystems = [ "ntfs" ];

    #? Loader
    loader = {
      timeout = 5;
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = false;
      };


    kernelPackages = pkgs.linuxPackages_latest;
    extraModulePackages = with config.boot.kernelPackages; [
    virtualbox
    #rtl8188eus-aircrack
    #acpi_call
    #hpuefi-mod
    #tp_smapi
    ];

    kernelModules = [
    "kvm-intel" "uinput" "vfio" "vfio_iommu_type1" "vfio_pci" "hp_wmi" "drivetemp"
    "cpufreq_ondemand" "cpufreq_conservative"   # CPU governors
    "acpi-cpufreq"                              # Enable ACPI CPU frequency driver
    #"vboxdrv" "vboxnetadp" "vboxnetflt"         # Virtual box
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
    kernelModules = [
    "amdgpu"
    "cpufreq_ondemand"
    "cpufreq_conservative"
    "acpi-cpufreq"
    ];
    availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usb_storage" "sd_mod"
    "iwlwifi"
    ];
  };

    consoleLogLevel = 3;

    kernel.sysctl = {
      "scaling_governor" = "conservative";

      "vm.laptop_mode" = 1;                             # Enable Laptop mode for disk spindown
      "kernel.nmi_watchdog" = 0;                        # Disable NMI watchdog for power saving
      "vm.dirty_bytes" = 16777216;                      # 16MB write threshold
      "vm.dirty_background_bytes" = 8388608;            # 8MB background threshold
      "usbcore.autosuspend_delay_ms" = 2000;            # 2-second delay, balances power and responsiveness
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
