{ lib, pkgs, ... }:

with lib;
mkMerge [
  # Kernel and boot security configurations
  {
    boot.kernel.sysctl = mkMerge [
      # Core kernel security settings
      {
        "kernel.dmesg_restrict" = mkForce 1;
        "fs.suid_dumpable" = mkOverride 500 0;
        "kernel.ftrace_enabled" = mkDefault false;
        "net.core.bpf_jit_enable" = mkDefault false;
      }

      # IPv6 disable configuration
      {
        "net.ipv6.conf.lo.disable_ipv6" = mkForce 1;
        "net.ipv6.conf.all.disable_ipv6" = mkForce 1;
        "net.ipv6.conf.default.disable_ipv6" = mkForce 1;
      }

      # TCP/SYN flood protection
      {
        "net.ipv4.tcp_syncookies" = mkForce 1;
        "net.ipv4.tcp_syn_retries" = mkForce 2;
        "net.ipv4.tcp_synack_retries" = mkForce 2;
        "net.ipv4.tcp_max_syn_backlog" = mkForce 4096;
      }

      # keepalive for connection maintenance
      {
        "net.ipv4.tcp_keepalive_time" = mkForce 60;
        "net.ipv4.tcp_keepalive_intvl" = mkForce 10;
        "net.ipv4.tcp_keepalive_probes" = mkForce 6;

      }

      # Larger buffer for handling connection instability
      {
          "net.core.rmem_max" = mkForce 2500000;
          "net.core.wmem_max" = mkForce 2500000;
      }

      # Additional network security
      {
        "net.ipv4.tcp_rfc1337" = mkForce 1;
        "net.ipv4.conf.all.rp_filter" = mkForce 1;
        "net.ipv4.icmp_echo_ignore_all" = mkForce 1;
        "net.ipv4.conf.default.rp_filter" = mkForce 1;
        "net.ipv4.conf.all.log_martians" = mkDefault true;
        "net.ipv4.conf.default.log_martians" = mkDefault true;
        "net.ipv4.icmp_ignore_bogus_error_responses" = mkForce 1;
      }
    ];

    # Console log level configuration
    boot.consoleLogLevel = mkOverride 500 3;

    # Blacklisted kernel modules
    boot.blacklistedKernelModules = mkForce [
      # Flatpak
      "flatpak"

      # Obscure network protocols
      "ax25"
      "netrom"
      "rose"

      # Legacy/rare filesystems
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
  }

  # Service configurations
  {
    # Disable CUPS
    services.printing.enable = mkForce false;

    # Enable Fail2ban
    services.fail2ban.enable = true;

    # Configure firmware updates
    services.fwupd = {
      enable = true;
      uefiCapsuleSettings = {
        DisableQuiet = true;
        DisableUefiReboot = true;
      };
    };

    # Disable KWallet PAM integration
    security.pam.services.sddm.kwallet.enable = false;

    # ClamAV configuration
    services.clamav = {

      scanner.enable = true;
      daemon.enable = true;
      updater = {
        enable = true;
        interval = "daily";
          settings = {
            # Enable multithreading
            MaxThreads = 4;  # Adjust based on CPU cores

            # Debug and logging
            LogFile = "/var/log/clamav/clamd.log";
            LogTime = true;
            LogClean = false;
            LogVerbose = false;
          };
      };
      fangfrisch = {
        enable = true;
        interval = "weekly";
      };
    };
  }

  # Package configurations
  {
    environment.systemPackages = with pkgs; [
      clamtk
    ];
  }
]