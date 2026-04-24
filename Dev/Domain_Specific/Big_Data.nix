{ pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    hadoop
    pig
    (lib.lowPrio spark)
  ];

  services.hadoop = {
    hdfs = {
      namenode = {
        enable = true;
        openFirewall = true;
        formatOnInit = true;   # ← auto-format on first start
      };
      datanode = {
        enable = true;
        openFirewall = true;
      };
    };

    yarn = {
      resourcemanager.enable = true;
      nodemanager = {
        enable = true;
        useCGroups = false;
      };
    };

    coreSite = {
      "fs.defaultFS" = "hdfs://localhost:9000";
    };

    hdfsSite = {
      "dfs.replication" = "1";
      "dfs.support.append" = "true";
      "dfs.permissions.enabled" = "false";  # ← ADD THIS
      "dfs.namenode.name.dir" = "/var/lib/hadoop/hdfs/namenode";
      "dfs.datanode.data.dir" = "/var/lib/hadoop/hdfs/datanode";
    };

    mapredSite = {
      "mapreduce.framework.name" = "yarn";
    };

    yarnSite = {
      "yarn.nodemanager.aux-services" = "mapreduce_shuffle";
      "yarn.resourcemanager.hostname" = "localhost";
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/hadoop/hdfs/namenode 0750 hdfs hadoop -"
    "d /var/lib/hadoop/hdfs/datanode 0750 hdfs hadoop -"
  ];

  programs.java.enable = true;

  security.pam.loginLimits = [
    { domain = "*"; type = "soft"; item = "nofile"; value = "65536"; }
    { domain = "*"; type = "hard"; item = "nofile"; value = "65536"; }
  ];

  users.users.masrkai.extraGroups = [ "hadoop" ];
}