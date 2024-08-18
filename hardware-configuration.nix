{ config, lib, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelModules = [ "kvm-intel" "radeon.si_support=1" "amdgpu.si_support=0" ];
  boot.extraModulePackages = [config.boot.kernelPackages.rtl8188eus-aircrack ];

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

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
