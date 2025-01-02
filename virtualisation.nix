{ lib, pkgs, ... }:
{

 environment.systemPackages = with pkgs; [
  #>################
  #> Virtualization:
  #>################
  qemu_full
  qemu-utils

  virt-viewer
  virt-manager

  spice
  spice-protocol

  win-spice
  win-virtio

  virtiofsd
  virglrenderer

  virtio-win
 ];

   #--> Qemu KVM & VirtualBox
    virtualisation = lib.mkForce {
    spiceUSBRedirection.enable = true;
      libvirtd = {
        enable = true;
        onBoot = "start";
        allowedBridges = [ "virbr0"];

        qemu = {
          package = pkgs.qemu_full;
          runAsRoot = true;
          swtpm.enable = true;

          ovmf = {
            enable = true;
            packages = [(pkgs.OVMFFull.override {
            secureBoot = true;
            tpmSupport = true;
          }).fd];
          };
        };
      };
    };
    services.spice-vdagentd.enable = false;
    programs.virt-manager.enable   = true;
    programs.dconf.enable = true;
}