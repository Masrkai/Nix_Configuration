{ pkgs }:

pkgs.writeScriptBin "setupcpp" ''
  #!${pkgs.bash}/bin/bash
  ${builtins.readFile ./setupcpp.sh}
''