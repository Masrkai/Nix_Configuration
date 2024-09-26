{ config, lib, pkgs, ... }:
{
      imports =
    [ # Include the results of the hardware scan.
      ../hardware-configuration.nix
      ../networking.nix
      ../security.nix
      ../bash.nix
    ];


}