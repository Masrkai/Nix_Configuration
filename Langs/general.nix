{ pkgs, ... }:

{

  general-marketplace-extensions = with pkgs.vscode-utils.extensionsFromVscodeMarketplace; [
      {
        # https://marketplace.visualstudio.com/items?itemName=AmazonWebServices.aws-toolkit-vscode
        name = "aws-toolkit-vscode";
        publisher = "AmazonWebServices";
        version = "3.55.0";
        hash = "sha256-cipckVnoqgX8Sll2Qkm05E3L9cja1x8hzKIv3HvnPyU=";

      }
      {
        #AmazonWebServices.amazon-q-vscode
        name = "amazon-q-vscode";
        publisher = "AmazonWebServices";
        version = "1.60.0";
        hash = "sha256-w3rsYEmIAkDtCsUlsrksMo9XYrrpdLCGhOufogWil2E=";

      }
      {
        #https://open-vsx.org/extension/lukinco/lukin-vscode-theme
        name = "lukin-vscode-theme";
        publisher = "lukinco";
        version = "0.1.5";
        hash = "sha256-T6yCPCy2AprDqNTJk2ucN2EsCrODn4j/1oldSnQNigU=";
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