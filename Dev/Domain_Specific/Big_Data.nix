{ pkgs, ... }:

{
   environment.systemPackages = with pkgs; [
   hadoop
      pig
      spark

  ];
}