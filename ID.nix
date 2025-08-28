# ID.nix - Simple hardware detection with global config
{ lib, config, pkgs, ... }:

let
  # Global configuration - change this path if needed
  hardwareConfigFile = "/etc/nixos/Sec/hardware-detected.nix";

in {
  options = {
    hardware = {
      isAsusTuf = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether this is an ASUS TUF Gaming laptop";
      };

      isThinkPad = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether this is a ThinkPad laptop";
      };

      isDellG15 = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether this is a Dell laptop";
      };
    };
  };

  config = {
    # Simple activation script that writes hardware config
    system.activationScripts.detectHardware = {
      text = ''
        if [ -r /sys/class/dmi/id/product_name ]; then
          PRODUCT_NAME=$(cat /sys/class/dmi/id/product_name | tr -d '[:space:]')
          echo "Detected hardware: $PRODUCT_NAME"

          # Determine flags based on detection
          if [ "$PRODUCT_NAME" = "ASUSTUFGamingA15FA507NVR_FA507NVR" ]; then
            ASUS_TUF_FLAG="true"
          else
            ASUS_TUF_FLAG="false"
          fi


          if [ "$PRODUCT_NAME" = "DellG155510" ]; then
            isDellG15_FLAG="true"
          else
            isDellG15_FLAG="false"
          fi


          if echo "$PRODUCT_NAME" | grep -q "ThinkPad"; then
            THINKPAD_FLAG="true"
          else
            THINKPAD_FLAG="false"
          fi

          # Write the hardware configuration file directly
          cat > ${hardwareConfigFile} << EOF
# Auto-generated hardware detection - DO NOT EDIT MANUALLY
{
  hardware.isAsusTuf = $ASUS_TUF_FLAG;
  hardware.isDellG15 = $isDellG15_FLAG;
  hardware.isThinkPad = $THINKPAD_FLAG;
}
EOF

          echo "Hardware config written to ${hardwareConfigFile}"
          echo "ASUS TUF: $ASUS_TUF_FLAG, ThinkPad: $THINKPAD_FLAG Dell G15: $isDellG15_FLAG"
        else
          echo "Could not detect hardware, using defaults"
        fi
      '';
      deps = [ ];
    };
  };
}