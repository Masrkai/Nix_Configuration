{ pkgs, ... }:
let
  unstable = import <unstable> {config.allowUnfree = true;};
in{
  environment.systemPackages = with unstable.pkgs;[

      #? 1st class citizen (if i could make it work)
      typst

      #> 2nd class citizen (works)
      (texliveMedium.withPackages (ps: with ps; [
        fontspec

      ]))

      pandoc
      pandoc-include
      pandoc-ext-diagram
        plantuml
        mermaid-cli

    ];


  # Set global environment variable
  environment.variables = {
    PLANTUML_JAR = "${unstable.pkgs.plantuml}/lib/plantuml.jar";
    PANDOC_DIAGRAM_FILTER = "${unstable.pkgs.pandoc-ext-diagram}/diagram.lua";
  };


}


