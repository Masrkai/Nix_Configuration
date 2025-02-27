{ pkgs, ... }:

{

  general-marketplace-extensions = with pkgs.vscode-utils.extensionsFromVscodeMarketplace; [

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
        #https://open-vsx.org/extension/KevinRose/vsc-python-indent
        name = "vsc-python-indent";
        publisher = "KevinRose";
        version = "1.18.0";
        hash = "sha256-hiOMcHiW8KFmau7WYli0pFszBBkb6HphZsz+QT5vHv0=";
      }
      {
        #https://open-vsx.org/api/bpruitt-goddard/mermaid-markdown-syntax-highlighting
        name = "mermaid-markdown-syntax-highlighting";
        publisher = "bpruitt-goddard";
        version = "1.6.6";
        hash = "sha256-1WwjGaYNHN6axlprjznF1S8BB4cQLnNFXqi7doQZjrQ=";
      }
      {
        #https://open-vsx.org/extension/ultram4rine/vscode-choosealicense
        name = "vscode-choosealicense";
        publisher = "ultram4rine";
        version = "0.9.4";
        hash = "sha256-YmZ1Szvcv3E3q8JVNV1OirXFdYI29a4mR3rnhJfUSMM=";
      }
      {
        #https://marketplace.visualstudio.com/items?itemName=yy0931.vscode-sqlite3-editor
        name = "vscode-sqlite3-editor";
        publisher = "yy0931";
        version = "1.0.189";
        hash = "sha256-zlZTb9zBSWsnZrcYArW1x4hjHzlAp6ITe4TPuUdYazI=";
      }
      {
        #https://open-vsx.org/extension/markwylde/vscode-filesize
        name = "vscode-filesize";
        publisher = "mkxml";
        version = "3.1.0";
        hash = "sha256-5485MjY3kMdeq/Z2mYaNjPj1XA+xRHizMrQDWDLWrf8=";
      }
      {
        # https://marketplace.visualstudio.com/items?itemName=cheshirekow.cmake-format
        name = "cmake-format";
        publisher = "cheshirekow";
        version = "0.6.11";
        hash = "sha256-NdU8J0rkrH5dFcLs8p4n/j2VpSP/X7eSz2j4CMDiYJM=";
      }
      {
        #https://marketplace.visualstudio.com/items?itemName=ms-python.pylint
        name = "pylint";
        publisher = "ms-python";
        version = "2023.11.13481007";  # Check for the latest version
        hash = "sha256-rn+6vT1ZNpjzHwIy6ACkWVvQVCEUWG2abCoirkkpJts=";
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