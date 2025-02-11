{ lib, config, pkgs, ... }:

let
  secrets = import ../Sec/secrets.nix;
in
{

  boot.extraModprobeConfig = ''
    options cfg80211 ieee80211_regdom=${secrets.WG}
  '';

  #  boot.extraModprobeConfig = ''
  #   options cfg80211 ieee80211_regdom="${secrets.WG}"
  # '';

  hardware = lib.mkMerge [
    {
      wirelessRegulatoryDatabase = true;
      firmware = with pkgs; [ wireless-regdb ];
    }
  ];

}