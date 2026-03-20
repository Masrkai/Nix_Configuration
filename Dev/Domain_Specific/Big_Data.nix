{ pkgs, ... }:

{
   environment.systemPackages = with pkgs; [
   hadoop
      pig
      (lib.lowPrio spark)

  ];
}