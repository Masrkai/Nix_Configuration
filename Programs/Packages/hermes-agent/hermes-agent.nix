{ config, pkgs, lib, ... }:

let
  cfg = config.services.hermes-agent;
  hermes = pkgs.callPackage ./package.nix { };
in
{
  options.services.hermes-agent = {
    enable = lib.mkEnableOption "Hermes Agent gateway";

    environmentFile = lib.mkOption {
      type    = lib.types.path;
      description = "Path to file containing API keys (not in Nix store)";
      example = "/run/secrets/hermes-env";
    };

    stateDir = lib.mkOption {
      type    = lib.types.str;
      default = "/var/lib/hermes";
    };

    model = lib.mkOption {
      type    = lib.types.str;
      default = "anthropic/claude-sonnet-4";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.hermes = {
      isSystemUser = true;
      group        = "hermes";
      home         = cfg.stateDir;
      createHome   = true;
    };
    users.groups.hermes = {};

    systemd.services.hermes-agent = {
      description   = "Hermes Agent Gateway";
      wantedBy      = [ "multi-user.target" ];
      after         = [ "network-online.target" ];
      wants         = [ "network-online.target" ];

      serviceConfig = {
        User             = "hermes";
        Group            = "hermes";
        WorkingDirectory = cfg.stateDir;
        EnvironmentFile  = cfg.environmentFile;
        ExecStart        = "${hermes}/bin/hermes gateway run";
        Restart          = "always";
        RestartSec       = 5;

        # Hardening
        NoNewPrivileges  = true;
        ProtectSystem    = "strict";
        ProtectHome      = true;
        PrivateTmp       = true;
        ReadWritePaths   = [ cfg.stateDir ];
      };

      environment = {
        HERMES_HOME  = "${cfg.stateDir}/.hermes";
        HERMES_MODEL = cfg.model;
      };
    };
  };
}