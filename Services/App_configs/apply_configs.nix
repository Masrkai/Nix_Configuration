{ config, lib, pkgs, modulesPath, ... }:

let
  username = "masrkai";

  # Copy files into the Nix store instead of reading them
  configFiles = {
    btop = /etc/nixos/Services/App_configs/btop.conf;
    kitty = /etc/nixos/Services/App_configs/kitty.conf;
    ghostty = /etc/nixos/Services/App_configs/ghostty.conf;
  };

in
{
  systemd.services."Environment_Insurance" = {
    description = "Ensure system configurations are in place";
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      ExecStart = pkgs.writeShellScript "setup-configs" ''
        # btop
        mkdir -p ~/.config/btop/
        ${pkgs.coreutils}/bin/cp ${configFiles.btop} ~/.config/btop/btop.conf

        # kitty
        mkdir -p ~/.config/kitty/
        ${pkgs.coreutils}/bin/cp ${configFiles.kitty} ~/.config/kitty/kitty.conf

        # ghostty
        mkdir -p ~/.config/ghostty/
        ${pkgs.coreutils}/bin/cp ${configFiles.ghostty} ~/.config/ghostty/config

        # clangd
        mkdir -p ~/.config/clangd/
        ${pkgs.coreutils}/bin/cat > ~/.config/clangd/config.yaml << 'EOF'
        CompileFlags:
          Add: ["-stdlib=libstdc++"]
        Index:
          Background: Build
        Diagnostics:
          UnusedIncludes: Strict
        Hover:
          ShowAKA: Yes
        EOF

        # jackett
        mkdir -p ~/.local/share/qBittorrent/nova3/engines/
        ${pkgs.coreutils}/bin/cat > ~/.local/share/qBittorrent/nova3/engines/jackett.json << 'EOF'
        {
            "api_key": "n1asleravzpgw5pq7jxtpsmg3oc5inyc",
            "thread_count": 20,
            "tracker_first": false,
            "url": "http://127.0.0.1:9117"
        }
        EOF
      '';

      User = username;
      Type = "oneshot";
      RemainAfterExit = true;
      ProtectHome = false;
      DynamicUser = false;
      NoNewPrivileges = true;
      ProtectSystem = "strict";

      CapabilityBoundingSet = [ "CAP_CHOWN" "CAP_DAC_OVERRIDE" ];
      AmbientCapabilities = [ "CAP_CHOWN" "CAP_DAC_OVERRIDE" ];

      RestrictAddressFamilies = [
        "~AF_UNIX" "~AF_INET" "~AF_INET6" "~AF_PACKET"
        "~AF_NETLINK" "~AF_BLUETOOTH"
      ];

      SystemCallFilter = [
        "~@swap" "~@clock" "~@debug" "~@mount" "~@module"
        "~@raw-io" "~@reboot" "~@obsolete" "~@resources"
        "~@privileged" "~@cpu-emulation"
      ];
    };
  };
}