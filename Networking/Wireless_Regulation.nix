{ lib, config, pkgs, ... }:

let
  secrets = import ../Sec/secrets.nix;
in
{

  # boot.extraModprobeConfig = ''
  #   options rtw89_pci disable_clkreq=1 disable_aspm_l1=1 disable_aspm_l1ss=1
  # '';



  # boot.extraModprobeConfig = ''
  #   options cfg80211 ieee80211_regdom=${secrets.WG}
  # '';

  # hardware = lib.mkMerge [
  #   {
  #     wirelessRegulatoryDatabase = true;
  #     firmware = with pkgs; [ wireless-regdb ];
  #   }
  # ];

}