{ lib, pkgs, ... }:

{

  general-nixpkgs-extensions = with pkgs.vscode-extensions; [
    continue.continue
  ];

  general-marketplace-extensions = with pkgs.vscode-utils.extensionsFromVscodeMarketplace; [
      {
        #https://open-vsx.org/extension/lukinco/lukin-vscode-theme
        name = "lukin-vscode-theme";
        publisher = "lukinco";
        version = "0.1.5";
        hash = "sha256-T6yCPCy2AprDqNTJk2ucN2EsCrODn4j/1oldSnQNigU=";
      }





      {
        # https://marketplace.visualstudio.com/items?itemName=TheQtCompany.qt-core
        name = "qt-core";
        publisher = "TheQtCompany";
        version = "1.9.0";
        hash = "sha256-IpqsDfhx9UIA3jm/BkPW9mzMkr+muvvhak/wPZb8HQA=";
      }
      {
        # https://marketplace.visualstudio.com/items?itemName=TheQtCompany.qt-cpp
        name = "qt-cpp";
        publisher = "TheQtCompany";
        version = "1.9.0";
        hash = "sha256-S2r2vPRHeYXKwdq6Lu3z7ayecs7vY2BQaXtn5uTvsH4=";
      }
      {
        # https://marketplace.visualstudio.com/items?itemName=TheQtCompany.qt-qml
        name = "qt-qml";
        publisher = "TheQtCompany";
        version = "1.9.0";
        hash = "sha256-cWS3xUAbPiH/Mqohs0reWNyfMLiSO7tXdIp7/GbTysw=";
      }
      {
        # https://marketplace.visualstudio.com/items?itemName=TheQtCompany.qt-ui
        name = "qt-ui";
        publisher = "TheQtCompany";
        version = "1.9.0";
        hash = "sha256-L0kgPbiF1KiLnfhyB5TK3XG5pCLZrNvfbV+kwbhXPks=";
      }



      {
        #https://marketplace.visualstudio.com/items?itemName=LucasFA.octaveexecution
        name = "octaveexecution";
        publisher = "LucasFA";
        version = "0.7.6";
        # hash = lib.fakeHash;
        hash = "sha256-oQ8Bwo7bCb0ecHrJz84Uisc4WgbuByfEol3luHZfSB8=";
      }
      {
        #https://open-vsx.org/extension/eliostruyf/screendown
        name = "screendown";
        publisher = "eliostruyf";
        version = "0.0.23";
        hash = "sha256-ZHa4N1QTj7XAizWgeXzRGohhsSbxdPJv1rtCib4sQsU=";
      }
      {
        #https://open-vsx.org/extension/ultram4rine/vscode-choosealicense
        name = "vscode-choosealicense";
        publisher = "ultram4rine";
        version = "0.9.4";
        hash = "sha256-YmZ1Szvcv3E3q8JVNV1OirXFdYI29a4mR3rnhJfUSMM=";
      }
      {
        #https://open-vsx.org/extension/markwylde/vscode-filesize
        name = "vscode-filesize";
        publisher = "mkxml";
        version = "3.1.0";
        hash = "sha256-5485MjY3kMdeq/Z2mYaNjPj1XA+xRHizMrQDWDLWrf8=";
      }
      {
        #https://marketplace.visualstudio.com/items?itemName=darkriszty.markdown-table-prettify
        name = "markdown-table-prettify";
        publisher = "darkriszty";
        version = "3.6.0";  # Check for the latest version
        hash = "sha256-FZTiNGSY+8xk3DJsTKQu4AHy1UFvg0gbrzPpjqRlECI=";
      }
      {
        #https://marketplace.visualstudio.com/items?itemName=goessner.mdmath
        name = "mdmath";
        publisher = "goessner";
        version = "2.7.4";  # Check for the latest version
        hash = "sha256-DCh6SG7nckDxWLQvHZzkg3fH0V0KFzmryzSB7XTCj6s=";
      }
      {
        #https://marketplace.visualstudio.com/items?itemName=shellscape.shellscape-brackets
        name = "shellscape-brackets";
        publisher = "shellscape";
        version = "0.1.2";  # Check for the latest version
        hash = "sha256-dcxtgUfn2GhVVyTxd+6mC0bhwMeLUxB6T9mPBUbgxbA=";
      }

  ];
}