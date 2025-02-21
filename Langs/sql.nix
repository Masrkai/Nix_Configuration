{ lib, pkgs, ... }:

{
  sqlpackages = with pkgs; [
   beekeeper-studio
   mysql-workbench
  ];

  sql-nixpkgs-extensions = with pkgs.vscode-extensions; [
   cweijan.vscode-database-client2
  ];

}