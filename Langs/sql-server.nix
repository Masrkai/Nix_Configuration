{ config, pkgs, lib, ... }:

let
  dbConfig = {
    db       = "mainDB";
    user     = "masrkai";
    password = "1";
  };
in {
  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    dataDir = "/var/lib/mysql";

    user = "mysql";
    group = "mysql";
    ensureDatabases = [ dbConfig.db ];

    initialScript = pkgs.writeText "mysql-init.sql" ''
      ALTER USER '${dbConfig.user}'@'localhost' IDENTIFIED BY '${dbConfig.password}';
      FLUSH PRIVILEGES;
    '';

    ensureUsers = [{
      name = dbConfig.user;
      ensurePermissions = {
        "${dbConfig.db}.*" = "ALL PRIVILEGES";  # Correct database (mainDB.*)
      };
    }];

    settings = {
      mysqld = {
        port = 3306;  # Standard MySQL port
        bind-address = "127.0.0.1";
        max_connections = 200;  # Remove quotes
        sql_mode = "STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION";
      };


    };
  };
}