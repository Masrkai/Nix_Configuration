{ lib, ... }:

{

  boot.kernel.sysctl = lib.mkMerge [
    {
      "net.ipv4.ip_forward" = lib.mkDefault 1;                           #? For Hotspot & Bridges

      "net.ipv4.tcp_base_mss" = lib.mkDefault 1024;                      #? Set the initial MTU probe size (in bytes)
      "net.ipv4.tcp_mtu_probing" = lib.mkDefault 1;                      #? MTU Probing

      "net.ipv4.tcp_rmem" = lib.mkForce "4096 1048576 16777216";  # min/default/max
      "net.ipv4.tcp_wmem" = lib.mkForce "4096 1048576 16777216";  # min/default/max

      "net.ipv4.tcp_timestamps" = lib.mkDefault 1;                       #? TCP timestamps
      "net.ipv4.tcp_max_tso_segments" =  lib.mkDefault 2;                #? limit on the maximum segment size

      #? Enable BBR congestion control algorithm
      "net.core.default_qdisc" = lib.mkDefault "fq";
      "net.ipv4.tcp_congestion_control" = lib.mkDefault "bbr";

      #? Memory preserving
      "vm.min_free_kbytes" = lib.mkForce 65536;

      #? Multipath TCP
      "net.mptcp.enabled" = 1;
      "net.mptcp.checksum_enabled" = 1;
    }
  ];

}