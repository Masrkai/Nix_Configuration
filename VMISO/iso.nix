{ config, pkgs, lib, ... }:

{
  imports = [
    ../configuration.nix  # Import your existing configuration
  ];

  boot.loader.timeout = lib.mkForce 10;

  # ISO-specific options
  boot.loader.grub.memtest86.enable = true;
  boot.supportedFilesystems = [ "btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs" ];

  # Enable copy-on-write for the ISO
  isoImage.squashfsCompression = "zstd -Xcompression-level 6";

  # Optional: Set a custom ISO name
  isoImage.isoName = "Main_NixOS_System.iso";
}

# sudo nixos-generate -c /etc/nixos/VMISO/iso.nix  -f iso
