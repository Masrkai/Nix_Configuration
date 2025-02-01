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

  #   # WebRTC leak prevention for Chromium-based browsers
  # environment.etc."chromium/policies/managed/policies.json".text = ''
  #   {
  #     "WebRtcIPHandlingPolicy": "disable_non_proxied_udp",
  #     "WebRtcUDPPortRange": "10000-10010",
  #     "WebRtcLocalIpsAllowedUrls": [""],
  #     "WebRtcAllowLegacyTLSProtocols": false
  #   }
  # '';

  # # WebRTC leak prevention for Firefox
  # environment.etc."firefox/policies/policies.json".text = ''
  #   {
  #     "policies": {
  #       "DisableWebRTC": true,
  #       "Preferences": {
  #         "media.peerconnection.enabled": false,
  #         "media.peerconnection.ice.default_address_only": true,
  #         "media.peerconnection.ice.no_host": true,
  #         "media.peerconnection.ice.proxy_only": true
  #       }
  #     }
  #   }
  # '';


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


# { config, lib, pkgs, modulesPath, ... }:

# {
#   imports = [
#       (modulesPath + "/installer/scan/not-detected.nix")
#     ];

#   boot = {
#     #-> Enable NTFS Support for windows files systems
#     supportedFilesystems = [ "ntfs" ];

#     # extraModprobeConfig =''
#     # options cfg80211 ieee80211_regdom="EG"
#     # '';

#     #? Loader
#     loader = {
#       timeout = 5;
#       systemd-boot.enable = true;
#       efi.canTouchEfiVariables = true;
#       };

#     kernelPackages = pkgs.linuxPackages_latest;
#     extraModulePackages = with config.boot.kernelPackages; [
#     #rtl8188eus-aircrack
#     #acpi_call
#     #hpuefi-mod
#     #tp_smapi
#     ];

#     kernelModules = [
#     "kvm-intel" "uinput" "vfio" "vfio_iommu_type1" "vfio_pci" "hp_wmi" "drivetemp"
#     "cpufreq_ondemand" "cpufreq_conservative"   # CPU governors
#     "acpi-cpufreq"                              # Enable ACPI CPU frequency driver
#     ];

#     #! Kernel parameters
#     kernelParams = [
#     "amdgpu.si_support=1" "amdgpu.cik_support=1"                # AMD GPU driver
#     "radeon.si_support=0" "radeon.cik_support=0"                # Disable Radeon GPU
#     "intel_pstate=disable"                                      # Disable Intel P-state driver to use acpi-cpufreq
#     "intel_iommu=on" "iommu=pt"                                 # Intel IOMMU settings
#     "pci_pm_async=0" "pcie_aspm=force"                          # Power management
#     "usbcore.autosuspend=1"                                     # Enable USB autosuspend for power savings
#     ];

#   #! Initial RAM disk configuration
#   initrd = {
#     kernelModules = [ "amdgpu" ];
#     availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usb_storage" "sd_mod" ];
#   };

#     consoleLogLevel = 3;

#     kernel.sysctl = {
#       #"vm.dirty_writeback_centisecs" = 1500;
#       #"vm.dirty_expire_centisecs" = 3000;
#       "vm.laptop_mode" = 5;                             # Enable Laptop mode for disk spindown
#       "kernel.nmi_watchdog" = 0;                        # Disable NMI watchdog for power saving
#     };

#   };

#   fileSystems."/" = {
#   device = "/sys/class/disk/by-uuid/c2973410-4dd5-4c19-a859-e2e1db7ec9b2";
#   fsType = "btrfs";
#   options = [
#     "subvol=@"
#     "noatime"
#     "nodiratime"
#     "discard=async"     # Instead of just "discard"
#     "space_cache=v2"    # Better space cache
#     "compress=zstd:1"   # Efficient compression
#     "ssd"               # Optimize for SSD
#     "autodefrag"        # Automatic defragmentation
#   ];
# };


# fileSystems."/boot" =
# { device = "/sys/class/disk/by-uuid/45FF-32D8";
#   fsType = "vfat";
# };

# services.fstrim = {
#   enable = false;
#   interval = "weekly";
# };

#   swapDevices = [ ];

#   nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

#   hardware = {
#       #firmware = with pkgs; [ wireless-regdb ];
#       #cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
#       enableAllFirmware = true;

#       #! Enable bluetooth
#       bluetooth = {
#         enable = true;
#         powerOnBoot = false;
#       };
#    };
#    services.blueman.enable = false;  # Disable Blueman

}


  #   fancontrol = {
  #     enable = false;
  #     config =
  #     ''
  #     INTERVAL=5  # Polling interval in seconds

  #     # Define path to the fan control and CPU temperature sensor
  #     DEVPATH=/dev/hwmon_coretemp
  #     DEVNAME=coretemp

  #     # Map PWM control to CPU temperature
  #     FCTEMPS=/dev/hwmon_coretemp/pwm1=/dev/hwmon_coretemp/temp1_input
  #     FCFANS=/dev/hwmon_coretemp/pwm1=/dev/hwmon_coretemp/fan1_input

  #     # Set temperature thresholds and fan speed
  #     MINTEMP=/dev/hwmon_coretemp/pwm1=45  # Fan off below 45°C
  #     MAXTEMP=/dev/hwmon_coretemp/pwm1=85  # Full speed at 85°C
  #     MINSTART=/dev/hwmon_coretemp/pwm1=50 # Minimum PWM speed to start the fan
  #     MINSTOP=/dev/hwmon_coretemp/pwm1=30  # PWM speed to stop the fan
  #     '';
  #   };
  # };

  # # #! For persistant Sensors names
  # services.udev.enable = true;
  # services.udev.extraRules = lib.mkForce ''
  #   # Persistent names for hwmon devices
  #   SUBSYSTEM=="hwmon", ATTR{name}=="amdgpu", SYMLINK+="hwmon_amdgpu"
  #   SUBSYSTEM=="hwmon", ATTR{name}=="hp", SYMLINK+="hwmon_hp"
  #   SUBSYSTEM=="hwmon", ATTR{name}=="coretemp", SYMLINK+="hwmon_coretemp"
  #   SUBSYSTEM=="hwmon", ATTR{name}=="acpitz", SYMLINK+="hwmon_acpitz"
  # '';



    # DNSCrypt-proxy configuration
  # services.dnscrypt-proxy2 = {
  #   enable = false;
  #   settings = {
  #     listen_addresses = [ "127.0.0.1:53" ];
  #     server_names = [ "cloudflare" ];
  #     forwarding_rules = "forwards.txt";

  #     log_level = 2;  # 0: none, 1: error, 2: info, 3: debug
  #     log_file = "/var/log/dnscrypt-proxy.log";
  #   };
  # };

  # # Create forwarding rules for DNSCrypt-proxy
  # environment.etc."dnscrypt-proxy/forwards.txt" = {
  #   text = ''
  #     * 127.0.0.1:5353
  #   '';
  #   mode = "0644";
  # };



  # services.unbound = {
  #   enable = true;
  #   resolveLocalQueries = false;
  #   stateDir = "/var/lib/unbound" ;
  #   settings = {
  #       server = {
  #         interface = [ "127.0.0.1" ];
  #         forward-zone = [                      # Forward to Stubby for encrypted DNS resolution
  #             {
  #               name = ".";
  #               forward-addr = "127.0.0.1@53";
  #             }
  #         ];

  #         # Performance and privacy settings
  #         prefetch = "yes";
  #         prefetch-key = "yes";
  #         hide-identity = "yes";
  #         hide-version = "yes";

  #         # Security settings
  #         val-log-level = 2;
  #         val-clean-additional = "yes";

  #         # Cache settings
  #         cache-max-ttl = 86400;
  #         cache-min-ttl = 3600;

  #         # DNSSEC
  #         module-config = "validator iterator";
  #         val-permissive-mode = "no";
  #       };
  #   };
  # };

  # powerManagement = {
  #   enable = true;
  #   powertop.enable = true;  # Optional but recommended for power management
  #   scsiLinkPolicy = "med_power_with_dipm";  # Enables SATA power management
  #  resumeCommands = ''
  # ${pkgs.kmod}/bin/modprobe -r psmouse
  # ${pkgs.kmod}/bin/modprobe psmouse
  # '';
  # };

  # systemd.services.unbound.after = [ "stubby.service" ];










      # # Create a script to handle DNS redirection
      # extraPackages = [ pkgs.iproute2 pkgs.bash ];
      
      # preCommands = ''
      #   # Flush existing DNS redirection rules
      #   nft flush chain ip nat dns_redirect 2>/dev/null || true
        
      #   # Create a new chain for DNS redirection if it doesn't exist
      #   nft add chain ip nat dns_redirect 2>/dev/null || true
        
      #   # Create DNS redirect base chain if it doesn't exist
      #   nft "add chain ip nat prerouting { type nat hook prerouting priority -100 ; }" 2>/dev/null || true
        
      #   # Add jump to dns_redirect chain
      #   nft add rule ip nat prerouting jump dns_redirect 2>/dev/null || true
      # '';
      
      # extraCommands = ''
      #   # Get all interfaces in AP/hotspot mode
      #   for iface in $(nmcli -g DEVICE,TYPE connection show --active | grep ":wifi" | cut -d: -f1); do
      #     # Check if interface is in AP mode
      #     if [ "$(iwconfig "$iface" 2>/dev/null | grep "Mode:Master")" ]; then
      #       # Add DNS redirection rules for this interface
      #       nft add rule ip nat dns_redirect iifname "$iface" udp dport 53 redirect to :53
      #       nft add rule ip nat dns_redirect iifname "$iface" tcp dport 53 redirect to :53
      #     fi
      #   done
      # '';
      
      # # Clean up rules when stopping the firewall
      # extraStopCommands = ''
      #   nft flush chain ip nat dns_redirect 2>/dev/null || true
      #   nft delete chain ip nat dns_redirect 2>/dev/null || true
      # '';



  # # Echo Cancellation and Noise Suppression for Microphone
  # hardware.pipewire = {
  #   spaPlugins = [ "support" "aec" "dsp" "webrtc-audio-processing" ]; # Enable advanced effects
  # };

    # services.system76-scheduler.settings.cfsProfiles.enable = true;

  # programs.noisetorch.enable = true;

  # #--> Enable sound with pipewire.
  #   sound.enable = true;
  #   security.rtkit.enable = true;
  #   hardware.pulseaudio.enable = false;

  #   services.pipewire = {
  #     enable = true;
  #     alsa.enable = true;
  #     pulse.enable = true;
  #   };

    # # Define the network check script
  # environment.etc."check-internet.sh" = {
  #   text = ''
  #     #!/bin/sh
  #     # Check for internet connectivity by pinging a reliable external host (e.g., Cloudflare's 1.1.1.1)
  #     if curl -s https://1.1.1.1 > /dev/null; then
  #       echo "Internet connection is working."
  #     else
  #       echo "No internet connection. Restarting stubby..."
  #       systemctl restart stubby.service
  #     fi
  #   '';
  #   mode = "0700";  # Only the owner (root) can read, write, and execute
  #   uid = 0;        # Set owner to root (user ID 0)
  #   gid = 0;        # Set group to root (group ID 0)
  # };

  # # Create a systemd service that runs the check-internet script periodically
  # systemd.services.check-internet = {
  #   description = "Check for internet connectivity and restart stubby if down";
  #   serviceConfig = {
  #     ExecStart = "/etc/check-internet.sh";
  #   };
  #   wantedBy = [ "multi-user.target" ];
  # };

  # # Create a systemd timer to run the check-internet service every 5 minutes
  # systemd.timers.check-internet = {
  #   description = "Run check-internet every 1 minute";
  #   wantedBy = [ "timers.target" ];
  #   timerConfig = {
  #     OnBootSec = "1min";   # First run 1 minute after boot
  #     OnUnitActiveSec = "1min";  # Run every 5 minutes
  #   };
  # };