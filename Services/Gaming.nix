{ config, lib, pkgs, modulesPath, ... }:

let
  customPackages = {
    #>! Binary / FHSenv
    proton-ge-bin = pkgs.callPackage ../Programs/Packages/proton-ge-bin.nix {};
  };
in
{

 environment.systemPackages = with pkgs; [
  lutris
  bottles
  heroic-unwrapped

  dxvk
  # vkd3d
  mangohud

  winetricks
  # wineWowPackages.stableFull

  #Games
  unciv
  mindustry-wayland
];

  #> Steam
  programs.steam = {
    enable = true;
    extest.enable = false;
      extraCompatPackages = with pkgs; [
        customPackages.proton-ge-bin
      ];
    gamescopeSession.enable = true;

    remotePlay.openFirewall = false; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = false; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = false; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  programs.gamescope.enable = true;

  programs.gamemode.enable = true;

}
