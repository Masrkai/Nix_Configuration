
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
      #(modulesPath + "/installer/scan/not-detected.nix")
  ];

  systemd.oomd = {
    enable = true;                        # Enable systemd-oomd
    enableRootSlice = true;               # Manage memory pressure for root processes
    enableUserSlices = true;              # Manage memory for user sessions, reducing per-user memory pressure
    enableSystemSlice = true;             # Monitor and manage system services to avoid OOM issues
      extraConfig = {
        MemoryPressureDurationSec="10s";             # Faster response to memory issues
        DefaultMemoryPressureThresholdPercent=50;    # More aggressive memory protection
      };
  };


  boot = {
    consoleLogLevel = 3;

    supportedFilesystems = [              #-> Enable NTFS Support for windows files systems
                             "ntfs"       #-> Windows Filesystem
                             "ntfs-3g"    #-> Additional windows support
    ];

    #? boot Loader
    loader = {
        systemd-boot = {
          enable = true;
          consoleMode = "max";  # Better resolution for boot menu
          editor = false;       # Disable boot entry editing for security
        };
      timeout = 7;
      efi.canTouchEfiVariables = false;
    };

    kernelPackages = pkgs.linuxPackages_latest;
    extraModulePackages = with config.boot.kernelPackages; [
                                                            #rtl8188eus-aircrack
                                                            #virtualbox
    ];

    kernelModules = [
                      "kvm-intel" "uinput" "vfio" "vfio_iommu_type1" "vfio_pci" "hp_wmi" "drivetemp"
                      #"vboxdrv" "vboxnetadp" "vboxnetflt"         # Virtual box
                      "cpufreq_conservative"                       # CPU governor
                      "acpi-cpufreq"                               # Enable ACPI CPU frequency driver
                      "iwlwifi"                                    # for the wireless card
                      "amdgpu"                                     #? For AMD graphics
    ];

    #! Kernel parameters
    kernelParams = [
                    #? AMD GPU drivers
                    "amdgpu.si_support=0" "amdgpu.cik_support=1" "amdgpu.dpm=1"   #* AMD GPU driver
                    "radeon.si_support=0" "radeon.cik_support=0"                  #! Disable Radeon GPU driver

                    "pci_pm_async=0" "pcie_aspm=force"                            #? Power management
                    "intel_pstate=disable"                                        #! Disable Intel P-state driver to use acpi-cpufreq
                    "splash"                                                      #* show logo of your system

                    "usbcore.autosuspend=1"                                       #* Enable USB autosuspend for power savings

                    "intel_iommu=sm_on" "iommu=pt"                                #* Intel IOMMU security

                    #! Memory security
                    "page_alloc.shuffle=1"                                        #* Helps detect memory issues earlier + Major security Gain
                    "init_on_free=1"                                              #* Fill freed pages and heap objects with zeroes.
                    "vsyscall=none"                                               #! Disables legacy system call interface
                    "slab_nomerge" "slub_debug=FZ"                                #! Disables the merging of slabs of similar sizes & Enables sanity checks (F) and redzoning (Z).

                    #? GPU powersaving
                    #"i915.enable_dc=1"                                           #* Enable intel's iGPU deep power-saving states
                    "i915.enable_psr=1"                                           #* Enable intel's iGPU Panel Self Refresh for screens
                    "i915.enable_fbc=1"                                           #* Enable intel's iGPU Frame Buffer Compression
                    #"i915.enable_rc6=1"                                          #* Enable intel's iGPU power-saving modes

                    "acpi_osi=Linux"                                              #* Ensuring best behavior
                    "nowatchdog"                                                  #* Disable watchdog //no use for it in my case
    ];

    #! Initial RAM disk configuration
    initrd = {
      kernelModules = [
                        #"cpufreq_conservative" "acpi-cpufreq"  #! Important for CPU
                        #"amdgpu"                               #! For AMD graphics
      ];
      availableKernelModules = [
                                "xhci_pci"                      #? USB 3.0 controller
                                "ehci_pci"                      #? USB 2.0 controller
                                "ahci"                          #? SATA controller
                                "usb_storage"                   #? USB storage devices
                                "sd_mod"                        #? SCSI disk support
      ];
    };

    kernel.sysctl = {
      "scaling_governor" = "conservative";

      "vm.laptop_mode" = 1;                             # Enable Laptop mode for disk spindown
      "kernel.nmi_watchdog" = 0;                        # Disable NMI watchdog for power saving
      "vm.dirty_bytes" = 16777216;                      # 16MB write threshold
      "vm.dirty_background_bytes" = 8388608;            # 8MB background threshold
      "usbcore.autosuspend_delay_ms" = 2000;            # 2-second delay, balances power and responsiveness

      "vm.memory_failure_recovery" = 1;                 # enables the kernel's memory failure recovery mechanism
      "vm.memory_failure_early_kill" = 1;               # If a process is using memory pages that are failing, this parameter makes the kernel kill that process early
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
  zramSwap.enable = false;  # disable zram swap

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
