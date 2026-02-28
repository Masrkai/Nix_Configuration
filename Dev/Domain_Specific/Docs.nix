{ pkgs, ... }:

{
   environment.systemPackages = with pkgs; [
    doxygen
    doxygen_gui
    doxygen-awesome-css

    monolith
  ];
}