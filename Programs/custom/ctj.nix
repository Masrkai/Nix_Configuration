{ pkgs }:

let
  pythonWithPackages = pkgs.python312.withPackages (ps: with ps; [
    pyvips
  ]);
in
pkgs.writeScriptBin "ctj" ''
  #!${pythonWithPackages}/bin/python
  ${builtins.readFile ./ctj.py}
''