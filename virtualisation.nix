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

  # virtiofsd
  # virglrenderer

  # virtio-win
 ];

  users.groups.libvirt = {
  members = [ "masrkai" ];
  };

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
          vhostUserPackages = with pkgs; [
            virtiofsd
            virtio-win
            virglrenderer
          ];

          ovmf = {
            enable = true;
            packages = [(pkgs.OVMFFull.override {
            secureBoot = true;
            tpmSupport = true;
          }).fd];
          };
        };
      };

      podman = {
      enable = true;
      dockerCompat = true;
      #defaultNetwork.settings.dns_enabled = true;
      };

      oci-containers = {
        backend = "podman";
        containers = {
          open-webui = import ./containers/open-webui.nix;
        };
      };

    };
    services.spice-vdagentd.enable = true;
    programs.virt-manager.enable   = true;
    programs.dconf.enable = true;

    system.activationScripts = {
    script.text = ''
      install -d -m 755 ${builtins.getEnv "HOME"}/open-webui/data -o root -g root
    '';
   };


  # networking.interfaces.br0 = {
  # ipv4.addresses = [
  #   { address = "192.168.1.2"; prefixLength = 24; }
  # ];
  # ipv4.gateway = "192.168.1.1";
  # };
}