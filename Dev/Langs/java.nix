{ pkgs, ... }:

{

   programs.java = {
      enable = true;
      binfmt = true;
      # package = pkgs.temurin-bin-21;
   };
   # environment.systemPackages = with pkgs; [
   #  temurin-bin-25
   # ];
}