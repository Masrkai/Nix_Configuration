{ config, lib, pkgs, modulesPath, ... }:

let
  customPackages = {
    #? Java
    jsql        = pkgs.callPackage ../Programs/Packages/jsql.nix {};

    #? Python
    evillimiter = pkgs.callPackage ../Programs/Packages/evillimiter.nix {};

    #? GO
    evilginx    = pkgs.callPackage ./Programs/Packages/evilginx.nix {};


    #! Unknown (Need Looking)
    wifi-honey  = pkgs.callPackage ../Programs/Packages/wifi-honey.nix {};
    hostapd-wpe = pkgs.callPackage ../Programs/Packages/hostapd-wpe.nix {};

  };
in
{

    environment.systemPackages = with pkgs;
    [

      #!####################
      #! Pentration-Testing:
      #!####################
        #> Terminals
        xterm

        #> Password cracking
        crunch
        hashcat
        hcxtools
        hcxdumptool
        zip2hashcat
        hashcat-utils

        #> Internet basics
        iw
        dig
        nmap
        getdns
        linssid
        tcpdump
        ettercap
        iproute2
        arp-scan
        inetutils
        traceroute

        bettercap
        burpsuite

        #> DoS
        hping

        #> Wireless
        mdk4
        airgorah
        aircrack-ng
        linux-wifi-hotspot

          #> WPS
          bully
          pixiewps
          reaverwps-t6x

        #> MITM
        # customPackages.beef
        customPackages.wifi-honey
        customPackages.evillimiter


        #> Utilities
        tmux
        asleap
        lighttpd

        #> Exploitation
        # armitage
        exploitdb
        metasploit
        armitage

        #> SQL
        sqlmap
        customPackages.jsql

        #> Evil Twin
        dnsmasq
        dhcpcd
        cni-plugins
        customPackages.hostapd-wpe
    ];


}