#*#########################
#* Vscodium Configuration:
#*#########################

{ lib, pkgs, config, ... }:

let
  # unstable = import <unstable> {config.allowUnfree = true;};

  sql = import ./sql.nix { inherit pkgs lib ; };
  cpp = import ./cpp.nix { inherit pkgs lib ; };
  nixX = import ./nix.nix { inherit pkgs lib ; };
  umlx = import ./UML.nix { inherit pkgs lib ; };
  rust = import ./rust.nix { inherit pkgs lib ; };
  dartX = import ./dart.nix { inherit pkgs lib ; };
  pythonX = import ./python.nix{ inherit pkgs lib ; };
  generalX = import ./general.nix{ inherit pkgs lib ; };

in{
  environment.systemPackages = with pkgs;
  lib.flatten [  # Flatten the lists of packages
    sql.sqlpackages
    cpp.cpppackages
    nixX.nixpackages
    rust.rustpackages
    dartX.dartpackages
    pythonX.pythonpackages
    [
      # pandoc
      # pandoc-include
      # # pandoc-ext-diagram
      # pandoc-ext-diagram
      # mermaid-filter
      #     librsvg
      #     mermaid-cli
      # pandoc-lua-filters

      (vscode-with-extensions.override {
        vscode = vscodium;
        vscodeExtensions = with vscode-extensions; [
                            #* HTML
                            # ms-vscode.live-server
                            vscode-extensions.ritwickdey.liveserver

                            #* PDF
                            tomoki1207.pdf

                            #* Bash
                            mads-hartmann.bash-ide-vscode

                            #* Markdown
                            bierner.markdown-mermaid
                            shd101wyy.markdown-preview-enhanced
                            garlicbreadcleric.pandoc-markdown-syntax

                            #* Yamal
                            redhat.vscode-yaml

                            #* General
                            usernamehw.errorlens
                            donjayamanne.githistory      #> GIT History
                            mechatroner.rainbow-csv      #> For .csv files!
                            formulahendry.code-runner
                            shardulm94.trailing-spaces
                            aaron-bond.better-comments
                            streetsidesoftware.code-spell-checker

                            #? theming
                            pkief.material-icon-theme

                            #* VS-Codium Specific
                            editorconfig.editorconfig
                            github.vscode-pull-request-github

                            #? SSH
                            ms-vscode-remote.remote-ssh
                            ms-vscode-remote.remote-ssh-edit

                            #? MATLAB
                            # MathWorks.language-matlab
        ]
        ++ sql.sql-nixpkgs-extensions
        ++ cpp.cpp-nixpkgs-extensions
        ++ umlx.UML-nixpkgs-extensions
        ++ nixX.nix-nixpkgs-extensions
        ++ rust.rust-nixpkgs-extensions
        ++ dartX.dart-nixpkgs-extensions
        ++ pythonX.python-nixpkgs-extensions
        ++ generalX.general-nixpkgs-extensions


        ++ vscode-utils.extensionsFromVscodeMarketplace (
          cpp.cpp-marketplace-extensions
          ++ sql.sql-marketplace-extensions
          ++ umlx.UML-marketplace-extensions
          ++ nixX.nix-marketplace-extensions
          ++ rust.rust-marketplace-extensions
          ++ dartX.dart-marketplace-extensions
          ++ pythonX.python-marketplace-extensions
          ++ generalX.general-marketplace-extensions
        );
      })
    ]
  ];


  system.userActivationScripts.vscode-config = ''
    mkdir -p ~/.config/VSCodium/User
    cp ${./vscode_config.jsonc} ~/.config/VSCodium/User/settings.json
  '';

}
