{ pkgs }:

let
  pythonWithPackages = pkgs.python3.withPackages (ps: with ps; [
    pyvips
  ]);
in
pkgs.writeScriptBin "ctj" ''
  #!${pythonWithPackages}/bin/python
  ${builtins.readFile ./ctj.py}
''