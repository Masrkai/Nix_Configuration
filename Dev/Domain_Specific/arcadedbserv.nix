{ config, pkgs, ... }:

let
  arcadedb = pkgs.callPackage ./arcadedb.nix {
    jre_headless = pkgs.openjdk21_headless;
  };
in
{
  environment.systemPackages = [ arcadedb ];

  users.users.arcadedb = {
    isSystemUser = true;
    group = "arcadedb";
  };
  users.groups.arcadedb = {};

  systemd.services.arcadedb = {
    description = "ArcadeDB Server";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "simple";
      User = "arcadedb";
      Group = "arcadedb";
      WorkingDirectory = "/var/lib/arcadedb";
      StateDirectory = "arcadedb";   # creates /var/lib/arcadedb with correct ownership

      # ARCADEDB_HOME must point to the **immutable store path** where the JARs are.
      # The writable data directory is given via -Darcadedb.home system property.
      Environment = [
        "ARCADEDB_HOME=${arcadedb}/opt/arcadedb"
        ''"JAVA_OPTS=-Xmx2g -Xms512m -Darcadedb.home=/var/lib/arcadedb -Darcadedb.server.rootPassword=YourSecurePassword123"''
      ];

      ExecStart = "${arcadedb}/bin/arcadedb-server";
      Restart = "on-failure";
    };
  };

  # Open common ArcadeDB ports
  networking.firewall.allowedTCPPorts = [
    2480  # HTTP / Studio web interface
    2424  # Binary protocol
    5432  # PostgreSQL wire protocol
    7687  # Bolt (Neo4j) protocol
    # add 6379 for Redis, 27017 for MongoDB if you enable those modules
  ];
}