{ pkgs }:

let
  pythonWithPackages = pkgs.python312.withPackages (ps: with ps; [
      fire
      markdown2
      weasyprint
  ]);
in
pkgs.writeScriptBin "MD-PDF" ''
  #!${pythonWithPackages}/bin/python
  ${builtins.readFile ./MD-PDF.py}
''