{ pkgs }:

{
  ctj = let
    pythonWithPackages = pkgs.python312.withPackages (ps: with ps; [
      pyvips
    ]);
  in
  pkgs.writeScriptBin "ctj" ''
    #!${pythonWithPackages}/bin/python
    ${builtins.readFile ./ctj.py}
  '';

  mac-formatter = let
    pythonWithPackages = pkgs.python312.withPackages (ps: with ps; [
      # Add your dependencies here
    ]);
  in
  pkgs.writeScriptBin "mac-formatter" ''
    #!${pythonWithPackages}/bin/python
    ${builtins.readFile ./mac-formatter.py}
  '';

  MD-PDF = let
    pythonWithPackages = pkgs.python312.withPackages (ps: with ps; [
      fire
      markdown2
      weasyprint
    ]);
  in
  pkgs.writeScriptBin "MD-PDF" ''
    #!${pythonWithPackages}/bin/python
    ${builtins.readFile ./MD-PDF.py}
  '';
}