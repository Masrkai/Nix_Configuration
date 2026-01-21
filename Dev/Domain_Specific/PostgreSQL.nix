{ config, lib, pkgs, ... }:

let
  secrets = import ../../Sec/secrets.nix;

in{
  services.postgresql = {
    enable = false;
    enableTCPIP = true;

    authentication = pkgs.lib.mkOverride 10 ''
      # TYPE  DATABASE        USER            ADDRESS                 METHOD

      # Local socket connections
      local   all             all                                     trust

      # Localhost TCP connections with password
      host    all             all             127.0.0.1/32            scram-sha-256
      host    all             all             ::1/128                 scram-sha-256
    '';


    initialScript = pkgs.writeText "postgres-init-script" ''
      ALTER USER postgres PASSWORD '${secrets.postgres-secret-key}';
    '';

    settings = {
      port = 5432;
      max_connections = 100;
      shared_buffers = "256MB";
      effective_cache_size = "1GB";

      # Use scram-sha-256 for better security
      password_encryption = "scram-sha-256";

      # Reduce logging for better performance
      log_statement = "ddl";  # Only log DDL statements
      log_min_duration_statement = 1000;  # Log queries taking > 1 second
    };
  };

  # Optional: Open firewall for PostgreSQL (if you need external access)
  # networking.firewall.allowedTCPPorts = [ 5432 ];
}