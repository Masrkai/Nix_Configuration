{ pkgs, ... }:
let
  unstable = import <unstable> {config.allowUnfree = true;};
in{
  environment.systemPackages = with unstable.pkgs;[
      pandoc
      pandoc-include
      pandoc-ext-diagram
        mermaid-cli

    ];


  # Set global environment variable
  environment.variables = {
    PANDOC_DIAGRAM_FILTER = "${unstable.pkgs.pandoc-ext-diagram}/diagram.lua";
  };


}


