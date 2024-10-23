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

    # kernelPatches = [
    #   {
    #     name = "Rust Support";
    #     patch = null;
    #       features = {
    #         rust = true;
    #       };
    #   }
    # ];
  };

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/c2973410-4dd5-4c19-a859-e2e1db7ec9b2";
      fsType = "btrfs";
      options = [ "subvol=@" "noatime" "nodiratime" "discard" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/45FF-32D8";
      fsType = "vfat";
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
  };
}
