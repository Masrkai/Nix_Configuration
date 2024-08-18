{ pkgs }:

pkgs.writeScriptBin "backup" ''
  #!${pkgs.bash}/bin/bash
  ${builtins.readFile ./backup.sh}
''