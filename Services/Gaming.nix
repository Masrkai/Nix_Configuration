{ config, lib, pkgs, modulesPath, ... }:

let
  customPackages = {
    #>! Binary / FHSenv
    proton-ge-bin = pkgs.callPackage ../Programs/Packages/proton-ge-bin.nix {};

    proton_bottles =
      (pkgs.bottles.override { removeWarningPopup = true; }).overrideAttrs (old: {
        nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ pkgs.makeWrapper ];

        postInstall = (old.postInstall or "") + ''
          mkdir -p $out/share/bottles/runners
          # link the entire runner directory, not just the proton binary
          ln -s ${customPackages.proton-ge-bin} $out/share/bottles/runners/ge-proton10-17
        '';
      });

  };
in
{


environment.etc."skel/.local/share/bottles/runners/ge-proton10-17".source =
  "${customPackages.proton-ge-bin}/bin/proton";

 environment.systemPackages = with pkgs; [
  # lutris
  # bottles
  customPackages.proton_bottles
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
    extest.enable = true;
    protontricks.enable = true;
    gamescopeSession.enable = true;
    extraCompatPackages = with pkgs; [ customPackages.proton-ge-bin ];

    remotePlay.openFirewall = false;                # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = false;           # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = false; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  programs.gamemode.enable = true;
  programs.gamescope.enable = true;

}
