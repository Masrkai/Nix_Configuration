{
  # #! Enable DHCP server for the hotspot
  # services.kea.dhcp4 = {
  #   enable = true;
  #   settings = {
  #     interfaces-config = {
  #       interfaces = [ "wlan0" "wlan1" ];
  #       service-sockets-require-all = false;
  #       service-sockets-retry-wait-time = 5000;
  #     };
  #     lease-database = {
  #       type = "memfile";
  #       name = "/var/lib/kea/dhcp4.leases";
  #     };
  #     valid-lifetime = 4000;
  #     renew-timer = 1000;
  #     rebind-timer = 2000;
  #     subnet4 = [{
  #       id = 1;  # Add this line
  #       subnet = "10.42.0.0/24";
  #       pools = [{ pool = "10.42.0.2 - 10.42.0.254"; }];
  #       option-data = [
  #         { name = "routers"; data = "10.42.0.1"; }
  #         { name = "domain-name-servers"; data = "127.0.0.1"; }
  #         { name = "subnet-mask"; data = "255.255.255.0"; }
  #       ];
  #     }];
  #   };
  # };

  #! Nat for hotspot
  # networking.nat = {
  #   enable = true;
  #   externalInterface = "eth0";  # Adjust this to your main internet-connected interface
  #   internalInterfaces = [ "wlan0" "wlan1" ];
  # };

    # WebRTC leak prevention for Chromium-based browsers
  environment.etc."chromium/policies/managed/policies.json".text = ''
    {
      "WebRtcIPHandlingPolicy": "disable_non_proxied_udp",
      "WebRtcUDPPortRange": "10000-10010",
      "WebRtcLocalIpsAllowedUrls": [""],
      "WebRtcAllowLegacyTLSProtocols": false
    }
  '';

  # WebRTC leak prevention for Firefox
  environment.etc."firefox/policies/policies.json".text = ''
    {
      "policies": {
        "DisableWebRTC": true,
        "Preferences": {
          "media.peerconnection.enabled": false,
          "media.peerconnection.ice.default_address_only": true,
          "media.peerconnection.ice.no_host": true,
          "media.peerconnection.ice.proxy_only": true
        }
      }
    }
  '';


      # kernelModules  = [ "kvm-intel" "uinput" "vfio" "vfio_iommu_type1" "vfio_pci" "vfio_virqfd" "hp_wmi" "drivetemp"
    #                    "cpufreq_ondemand" "cpufreq_conservative"   #? CPU governores
    #                  ];

    # kernelParams   = [ "amdgpu.si_support=1" "amdgpu.cik_support=1"                                                      #? AMD GPU driver
    #                    "radeon.si_support=0" "radeon.cik_support=0"                                                      #? Disabling Radeon GPU
    #                    "intel_pstate=passive" "intel_pstate=no_hwp" "intel_iommu=on" "iommu=pt"                           #? Intel Specific
    #                    "pci_pm_async=0" "pcie_aspm=force" "i915.enable_dc=2" "i915.enable_fbc=1" "usbcore.autosuspend=1" #? Battery saving related
    #                  ];

    # initrd = {
    # kernelModules = [ "amdgpu" ];
    # availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usb_storage" "sd_mod" ];
    # };

    # TODO ---> Nginx
    # services.nginx = {
    #   enable = true;
    #   virtualHosts."localhost" = {
    #     listen = [{ addr = "127.0.0.1"; port = 443; ssl = true; }];
    #     sslCertificate = secrets.Nginx-ssl-Certificate;
    #     sslCertificateKey = secrets.Nginx-ssl-Certificate-Key;
    #     locations."/" = {
    #       proxyPass = "http://127.0.0.1:8888";
    #     };
    #   };
    # };

      #--> journald
    # systemd.journald = {
    #   SystemMaxUse = "100M";  # Adjust size if needed
    #   MaxRetentionSec = 2 * 24 * 60 * 60;  # Logs older than 2 days (in seconds) will be cleared
    # };
    # #--> journald
    # services.journald = {
    #   settings = {
    #   SystemMaxUse = "100M";    #? Adjust size if needed
    #   MaxRetentionSec = "2d";   #? Keep logs only for the last 2 days
    #   };
    # };

}