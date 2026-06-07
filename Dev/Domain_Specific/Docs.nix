{ pkgs, ... }:

let
  unstable = import <unstable> { config.allowUnfree = true; };
in {
  environment.systemPackages =
    (with pkgs; [
      doxygen
      doxygen_gui
      doxygen-awesome-css

      monolith
    ])
    ++
    (with unstable.pkgs; [
      typst
      (texliveMedium.withPackages (ps: with ps; [ fontspec ]))

      pandoc
      pandoc-include
      pandoc-ext-diagram

      librsvg
    ]);

  environment.variables = {
    PLANTUML_JAR = "${unstable.pkgs.plantuml}/lib/plantuml.jar";
    PANDOC_DIAGRAM_FILTER = "${unstable.pkgs.pandoc-ext-diagram}/diagram.lua";
  };
}
