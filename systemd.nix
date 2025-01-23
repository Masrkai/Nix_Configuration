{ config, lib, pkgs, modulesPath, ... }:


let
  # Define username as a variable at the top level
  username = "masrkai";
in
{

 systemd = {
    enableEmergencyMode = true;
      oomd = {
        enable = true;                        # Enable systemd-oomd
        enableRootSlice = true;               # Manage memory pressure for root processes
        enableUserSlices = true;              # Manage memory for user sessions, reducing per-user memory pressure
        enableSystemSlice = true;             # Monitor and manage system services to avoid OOM issues
          extraConfig = {
            MemoryPressureDurationSec="10s";             # Faster response to memory issues
            DefaultMemoryPressureThresholdPercent=50;    # More aggressive memory protection
          };
      };
      slices = {
          "system.slice" = {
            sliceConfig = {
              MemoryPressureLimit = 95;        # Memory pressure limit to trigger actions
              MemoryPressureDurationSec = "10s"; # How long pressure must persist before action
            };
          };

          "user.slice" = {
            sliceConfig = {
              MemoryPressureLimit = 95;
              MemoryPressureDurationSec = "10s";
            };
          };
      };


    # Main systemd sleep configuration
    sleep.extraConfig = ''
      [Sleep]
      AllowSuspend=yes
      SuspendMode=suspend
      SuspendState=mem
    '';

    services = {
      # Example of a systemd service override for NetworkManager
      NetworkManager = {
        serviceConfig = {
            # Isolation fundamentals - creating a secure execution environment
            PrivateTmp = true;
            ProtectHome = true;
            NoNewPrivileges = true;
            ProtectSystem = "strict";

            # Enhanced process isolation
            # PrivateUsers = true;       # Isolate user namespace
            ProtectClock = true;         # Prevent clock manipulation
            ProtectHostname = true;      # Prevent hostname changes
            LockPersonality = true;      # Lock down ABI personality
            ProcSubset = "all";          # Restrict /proc visibility
            ProtectProc = "ptraceable";  # Further /proc hardening

            # Device and kernel protection layers
            ProtectKernelLogs = true;
            ProtectKernelModules = true;
            ProtectControlGroups = true;
            ProtectKernelTunables = true;

            # Strategic exception for network devices while maintaining isolation
            PrivateDevices = false;  # NetworkManager needs direct device access

            # Capability bounding set - principle of least privilege in action
            CapabilityBoundingSet = [
                "CAP_NET_RAW"          # Required for ping, DHCP, and network diagnostics
                "CAP_NET_ADMIN"        # Essential for interface configuration
                "CAP_SYS_MODULE"       # Required for loading network drivers
                "CAP_AUDIT_WRITE"      # For security logging
                "CAP_NET_BIND_SERVICE" # Needed for privileged ports
            ];

            # Network protocol stack access control
            RestrictAddressFamilies = [
                "AF_UNIX"      # Local socket communication
                "AF_INET"      # IPv4 support
                "AF_INET6"     # IPv6 support
                "AF_PACKET"    # Raw packet manipulation
                "AF_NETLINK"   # Kernel networking communications
                "AF_BLUETOOTH" # Bluetooth support
            ];

            # Refined system call filter - allowing necessary privileged operations
            SystemCallFilter = [
                "@process"         # Process management
                "@network-io"      # Network operations
                "@privileged"      # Required privileged operations
                "@file-system"     # Filesystem operations
                "@system-service"  # Base system service calls

                "~@swap"           # Block swap operations
                "~@clock"          # Block unnecessary clock manipulation
                "~@debug"          # Block debugging
                "~@mount"          # Block mount operations
                "~@raw-io"         # Block raw I/O
                "~@reboot"         # Block reboot calls
                "~@obsolete"       # Block deprecated calls
                "~@resources"      # Block resource management
                "~@cpu-emulation"  # Block CPU emulation
            ];

            # Network security controls
            IPAddressDeny = "any";      # Default deny
            IPAddressAllow = [          # Allow only necessary
                "localhost"
                "link-local"
                "multicast"
            ];

            # Additional security hardening
            RestrictRealtime = true;             # Prevent scheduling interference
            RestrictSUIDSGID = true;             # Prevent privilege escalation
            RestrictNamespaces = "~user ~mnt ~cgroup ~ipc ~uts";  # Allow only network/pid namespaces

            MemoryDenyWriteExecute = true;       # Prevent code injection
            SystemCallArchitectures = "native";  # Prevent architecture-based attacks

            # File system and execution protections
            UMask = "0027";            # Restrictive file permissions
        };
      };


      "Jackett_Ensurance" = {
        description = "Create the jj.json file for qBittorrent";
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          ExecStart = let
            script = pkgs.writeShellScript "Jackett_Ensurance" ''
              ${pkgs.coreutils}/bin/cat > /home/${username}/.local/share/qBittorrent/nova3/engines/jackett.json << 'EOF'
              {
                  "api_key": "n1asleravzpgw5pq7jxtpsmg3oc5inyc",
                  "thread_count": 20,
                  "tracker_first": false,
                  "url": "http://127.0.0.1:9117"
              }
              EOF
            '';
          in "${script}";

          User = username;
          Type = "oneshot";
          ProtectHome = false;
          DynamicUser = false;
          RemainAfterExit = true;
          ReadWritePaths = [ "/home/${username}/.local/share/qBittorrent/nova3/engines/" ];

          NoNewPrivileges = true;
          ProtectSystem = "strict";

          CapabilityBoundingSet = [ "CAP_CHOWN" "CAP_DAC_OVERRIDE" ];
          AmbientCapabilities = [ "CAP_CHOWN" "CAP_DAC_OVERRIDE" ];

          # Network protocol stack access control
          RestrictAddressFamilies = [
                "~AF_UNIX"      # Local socket communication
                "~AF_INET"      # IPv4 support
                "~AF_INET6"     # IPv6 support
                "~AF_PACKET"    # Raw packet manipulation
                "~AF_NETLINK"   # Kernel networking communications
                "~AF_BLUETOOTH" # Bluetooth support
          ];

          SystemCallFilter= [
            "~@swap"
            "~@clock"
            "~@debug"
            "~@mount"
            "~@module"
            "~@raw-io"
            "~@reboot"
            "~@obsolete"
            "~@resources"
            "~@privileged"
            "~@cpu-emulation"
          ];



          # Ensure home directory is mounted
          RequiresMountsFor = [ "/home/${username}" ];
        };
      };



#-------------------------------------------------------------------------------->
    };
  };



}