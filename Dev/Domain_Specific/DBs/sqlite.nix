{ lib, pkgs, ... }:

{

 environment.systemPackages = with pkgs; [
   sqlite
   sqlitebrowser

   turso
   turso-cli
 ];
}
