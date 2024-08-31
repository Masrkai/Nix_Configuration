{ config, lib, pkgs, ... }:

with lib;
{

#--> Securing the system boot & kernel
  boot = {
    kernel.sysctl = {
        #? Disable ftrace debugging
        "kernel.ftrace_enabled" = mkDefault false;

        #? Restrict kernel log p1
        "kernel.dmesg_restrict" = mkForce 1;

        #? Restrict core dump
        "fs.suid_dumpable" = mkOverride 500 0;

        #? Disable bpf JIT compiler
        "net.core.bpf_jit_enable" = mkDefault false;

        #? Disable ipV6
        "net.ipv6.conf.lo.disable_ipv6" = mkForce 1;
        "net.ipv6.conf.all.disable_ipv6" = mkForce 1;
        "net.ipv6.conf.default.disable_ipv6" = mkForce 1;

        #? Prevent SYN Flooding
        "net.ipv4.tcp_syncookies" = mkForce 1;
        "net.ipv4.tcp_syn_retries" = mkForce 2;
        "net.ipv4.tcp_synack_retries" = mkForce 2;
        "net.ipv4.tcp_max_syn_backlog" = mkForce 4096;

                          #? Ignore ICMP echo requests
                          "net.ipv4.icmp_echo_ignore_all" = mkForce 1;

                          #? Prevent IP Spoofing attacks
                          "net.ipv4.conf.all.rp_filter" = mkForce 1;
                          "net.ipv4.conf.default.rp_filter" = mkForce 1;

                          #? Enable protection against time-wait assasination (RFC 1337)
                          "net.ipv4.tcp_rfc1337" = mkForce 1;

                          #? Log Martian packets
                          "net.ipv4.conf.all.log_martians" = mkDefault true;
                          "net.ipv4.conf.default.log_martians" = mkDefault true;

                          #? Ignore bogus ICMP error responses
                          "net.ipv4.icmp_ignore_bogus_error_responses" = mkForce 1;


    };
    #?> Restrict kernel log p2
    consoleLogLevel = mkOverride 500 3;
};


  boot.blacklistedKernelModules = [
    #! Flatpak
    "flatpak"

    #! Obscure network protocols
    "ax25"
    "netrom"
    "rose"

    #! Old or rare or insufficiently audited filesystems
    "adfs"
    "affs"
    "bfs"
    "befs"
    "cramfs"
    "efs"
    "erofs"
    "exofs"
    "freevxfs"
    "f2fs"
    "hfs"
    "hpfs"
    "jfs"
    "minix"
    "nilfs2"
    "omfs"
    "qnx4"
    "qnx6"
    "sysv"
    "ufs"
  ];


#--> Fail2ban // prevent brute-force attacks
services.fail2ban.enable = true;

#--> CalmAV
  services.clamav = {
    daemon = {
      enable = true;
    };
    updater = {
      enable = true;
      interval = "daily";
    };
  };

  # Ensure log directory exists with correct permissions
  systemd.tmpfiles.rules = [
    "d /var/log/clamav 0755 clamav clamav -"
  ];

  # Ensure the clamav user can write to its database directory
  system.activationScripts.clamavPermissions = ''
    mkdir -p /var/lib/clamav
    chown -R clamav:clamav /var/lib/clamav
  '';
}