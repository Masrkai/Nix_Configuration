{ lib, pkgs, config, ... }:
{

  environment.systemPackages = with pkgs; [
    #> Virtualization
    qemu-utils
    virt-viewer
    virt-manager
    spice
    spice-protocol
    virglrenderer  # Required for 3D acceleration
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
            win-spice
            virtiofsd
            virtio-win
            win-virtio
            virglrenderer
          ];

          verbatimConfig = ''
          cgroup_device_acl = [
            "/dev/null", "/dev/full", "/dev/zero",
            "/dev/random", "/dev/urandom", "/dev/ptmx",
            "/dev/kvm", "/dev/dri/renderD128"
          ]
          nvram = [ "${pkgs.OVMFFull}/FV/OVMF.fd:${pkgs.OVMFFull}/FV/OVMF_VARS.fd" ]
          '';

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
    services.spice-vdagentd.enable = true;
    programs.virt-manager.enable   = true;
    programs.dconf.enable = true;

    # environment.sessionVariables = {
    #   # Required for NVIDIA GL context sharing
    #   # OR explicitly reference the NVIDIA package:
    #   LIBGL_DRIVERS_PATH = "${config.hardware.nvidia.package}/lib/dri";
    #   __EGL_VENDOR_LIBRARY_DIRS = "${pkgs.mesa.drivers}/share/glvnd/egl_vendor.d";
    # };

    # # Render node permissions
    # services.udev.extraRules = ''
    #   KERNEL=="renderD128", GROUP="libvirt", MODE="0660"
    # '';


}