
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
    supportedFilesystems = [ "ntfs" "ntfs-3g" ];

    #? Loader
    loader = {
        systemd-boot = {
          enable = true;
          consoleMode = "max";  # Better resolution for boot menu
          editor = false;       # Disable boot entry editing for security
        };
      timeout = 5;
      efi.canTouchEfiVariables = false;
      };


    kernelPackages = pkgs.linuxPackages_latest;
    extraModulePackages = with config.boot.kernelPackages; [
    #rtl8188eus-aircrack
    #virtualbox
    ];

    kernelModules = [
    "kvm-intel" "uinput" "vfio" "vfio_iommu_type1" "vfio_pci" "hp_wmi" "drivetemp"
    "cpufreq_conservative"    # CPU governors
    #"vboxdrv" "vboxnetadp" "vboxnetflt"         # Virtual box
    "acpi-cpufreq"                               # Enable ACPI CPU frequency driver
    "iwlwifi"                                    # for the wireless card
    "amdgpu"                                     #? For AMD graphics
    ];

    #! Kernel parameters
    kernelParams = [
    "amdgpu.si_support=0" "amdgpu.cik_support=1" "amdgpu.dpm=1"   # AMD GPU driver
    "radeon.si_support=0" "radeon.cik_support=0"                  # Disable Radeon GPU
    "pci_pm_async=0" "pcie_aspm=force"                            # Power management
    "intel_iommu=on" "iommu=pt"                                   # Intel IOMMU settings
    "usbcore.autosuspend=1"                                       # Enable USB autosuspend for power savings
    "intel_pstate=disable"                                        # Disable Intel P-state driver to use acpi-cpufreq
    "splash"                                                      # show logo of your system
    ];

  #! Initial RAM disk configuration
  initrd = {
    kernelModules = [
    #"cpufreq_conservative" "acpi-cpufreq"  #? Important for CPU
    #"amdgpu"                               #? For AMD graphics
    ];
      availableKernelModules = [ 
        "xhci_pci"    # USB 3.0 controller
        "ehci_pci"    # USB 2.0 controller
        "ahci"        # SATA controller
        "usb_storage" # USB storage devices
        "sd_mod"      # SCSI disk support
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
    #"autodefrag"       #! Automatic defragmentation, why? it can increase write amplification on SSDs. If you aren't frequently modifying large files, you can disable this.
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
