{ lib, pkgs, ... }:
{
  # Enable KDE Plasma 6 Desktop Environment
  services.desktopManager.plasma6 = {
    enable = true;
    enableQt5Integration = false;
  };

  # Set default session to Wayland
  services.displayManager={
  defaultSession = "plasma";
    sddm = {
      enable = true;
          wayland = {
                enable = true;
                compositor = "kwin";
          };
      };
  };

  xdg ={
    icons.enable = true;
      portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-gnome
        kdePackages.xdg-desktop-portal-kde
      ];

    };
  };

  # Enable Wayland-specific services
  programs.xwayland.enable = true;
  services.xserver.enable = lib.mkForce false;

  environment = lib.mkMerge [
    {
      systemPackages = with pkgs; [
        wl-clipboard-rs
      ];
    }

    {
      variables = {
        GSK_RENDERER="nvidia";
        QT_QPA_PLATFORM="wayland";
        QT_SSL_FORCE_TLSV1_3 = "1";  # Enforce TLS 1.3 for Qt applications
        QT_SSL_FORCE_TLSV1_2 = "0";  # Disable TLS 1.2 (set to "1" if compatibility is required)
      };
      sessionVariables = {
        NIXOS_OZONE_WL = "1";
        XDG_SESSION_TYPE = "wayland";
        XDG_RUNTIME_DIR = "/run/user/$UID";


        KWIN_TRIPLE_BUFFER=1;
        PLASMA_USE_QT_SCALING=1;
        PLASMA_NOTIFICATION_DEBUG = "0";

        #QT_QPA_PLATFORM = "wayland";
        GDK_BACKEND = "wayland";
        WLR_NO_HARDWARE_CURSORS = "1";
      };
    }
  ];
}