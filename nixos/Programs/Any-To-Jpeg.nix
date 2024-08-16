{ pkgs }:

let
  pythonWithPackages = pkgs.python3.withPackages (ps: with ps; [
    pillow
  ]);
in
pkgs.writeScriptBin "ctj" ''
  #!${pythonWithPackages}/bin/python
  ${builtins.readFile ./Any-To-Jpeg.py}
''