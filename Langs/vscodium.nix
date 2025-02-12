#*#########################
#* Vscodium Configuration:
#*#########################

{ lib, pkgs, config, ... }:

let
  cpp = import ./cpp.nix { inherit pkgs lib ; };
  nixX = import ./nix.nix { inherit pkgs lib ; };
  rust = import ./rust.nix{ inherit pkgs lib ; };
  pythonX = import ./python.nix{ inherit pkgs lib ; };
  generalX = import ./general.nix{ inherit pkgs lib ; };

in{
  environment.systemPackages = with pkgs;
  lib.flatten [  # Flatten the lists of packages
    cpp.cpppackages
    nixX.nixpackages
    rust.rustpackages
    pythonX.pythonpackages
    [
      (vscode-with-extensions.override {
        vscode = vscodium;
        vscodeExtensions = with vscode-extensions; [
                            #* HTML
                            # ms-vscode.live-server
                            vscode-extensions.ritwickdey.liveserver

                            #* Bash
                            mads-hartmann.bash-ide-vscode

                            #* Markdown
                            bierner.markdown-mermaid
                            shd101wyy.markdown-preview-enhanced

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
        ]
        ++ cpp.cpp-nixpkgs-extensions
        ++ nixX.nix-nixpkgs-extensions
        ++ rust.rust-nixpkgs-extensions
        ++ pythonX.python-nixpkgs-extensions


        ++ vscode-utils.extensionsFromVscodeMarketplace (
          cpp.cpp-marketplace-extensions
          ++ nixX.nix-marketplace-extensions
          ++ rust.rust-marketplace-extensions
          ++ pythonX.python-marketplace-extensions
          ++ generalX.general-marketplace-extensions
        );
      })
    ]
  ];
}
