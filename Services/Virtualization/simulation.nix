{ pkgs, ... }:

let
  customPackages = {
    CiscoPacketTracer8 = pkgs.callPackage /etc/nixos/Programs/Packages/CiscoPacketTracer8.nix {};
  };
in
{

  environment.systemPackages = with pkgs; [

    # Scientific plotting and graphing program (OpenSource OriginLabs Alternative )
    veusz

    # # Mathematical Simulation (OpenSource Matlab Alternative)
    # octaveFull
    # octavePackages.image


    (octaveFull.withPackages (opkgs: with opkgs; [
      # signal
      # control
      # symbolic
      # statistics
      image
    ]))




    # Networking Simulation (Very Proprietary but needed for college)
    (customPackages.CiscoPacketTracer8.override { packetTracerSource = /etc/nixos/Programs/Packages/CiscoPacketTracer8.deb; })
  ];

}
