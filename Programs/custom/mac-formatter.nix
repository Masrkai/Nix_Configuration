{ pkgs }:

let
  pythonWithPackages = pkgs.python312.withPackages (ps: with ps; [
  ]);
in
pkgs.writeScriptBin "mac-formatter" ''
  #!${pythonWithPackages}/bin/python
  ${builtins.readFile ./mac-formatter.py}
''