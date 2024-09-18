{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot = {
    #-> Enable NTFS Support for windows files systems
    supportedFilesystems = [ "ntfs" ];

    #? Loader
    loader = {
      timeout = 5;
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      };

    kernelPackages = pkgs.linuxKernel.packages.linux_6_11;
    extraModulePackages = [
      #config.boot.kernelPackages.rtl8188eus-aircrack
      ];

    kernelModules  = [ "kvm-intel" "uinput" ];
    kernelParams   = [ "amdgpu.si_support=1" "amdgpu.cik_support=1" "radeon.si_support=0" "radeon.cik_support=0" ];

    initrd = {
    kernelModules = [ "amdgpu" ];
    availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usb_storage" "sd_mod" ];
    };

    consoleLogLevel = 3;
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
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

    #! Enable bluetooth
    bluetooth = {
      enable = true;
      powerOnBoot = false;
    };
  };
}
