{ pkgs, ... }:

{
   environment.systemPackages = with pkgs; [
    plantuml
    mermaid-cli
  ];
}