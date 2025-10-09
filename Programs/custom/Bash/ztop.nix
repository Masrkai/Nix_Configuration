{ pkgs }:

{
  # backup = pkgs.writeScriptBin "backup" ''
  #   ${builtins.readFile ./backup.sh}
  # '';

  extract = pkgs.writeScriptBin "extract" ''
    ${builtins.readFile ./extract.sh}
  '';

  setupcpp = pkgs.writeScriptBin "setupcpp" ''
    ${pkgs.bash}/bin/bash ${./setupcpp.sh}
  '';
}