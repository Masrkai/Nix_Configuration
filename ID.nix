# ID.nix
{ lib, ... }:

let
  # Read the product name from the system (trim whitespace/newlines)
  productName = builtins.readFile "/sys/class/dmi/id/product_name";
  cleanName = lib.strings.trim productName;

in {
  hardwareID = cleanName;

  # Example: provide booleans for known devices
  isAsusTuf = cleanName == "ASUS TUF Gaming A15 FA507NVR_FA507NVR";
  isThinkPad = lib.strings.hasInfix "ThinkPad" cleanName;
}
