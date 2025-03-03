{ lib, pkgs, ... }:

{
  sqlpackages = with pkgs; [
   beekeeper-studio
   mysql-workbench
  ];

  sql-nixpkgs-extensions = with pkgs.vscode-extensions; [
   cweijan.vscode-database-client2
  ];

  sql-marketplace-extensions = with pkgs.vscode-utils.extensionsFromVscodeMarketplace; [

      {
        #https://marketplace.visualstudio.com/items?itemName=yy0931.vscode-sqlite3-editor
        name = "vscode-sqlite3-editor";
        publisher = "yy0931";
        version = "1.0.189";
        hash = "sha256-zlZTb9zBSWsnZrcYArW1x4hjHzlAp6ITe4TPuUdYazI=";
      }
  ];
}