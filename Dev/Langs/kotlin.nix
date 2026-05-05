{pkgs, config, ... }:

{

  environment.systemPackages = with pkgs; [
    kotlin
    kotlin-native

    kotlin-language-server
    kotlin-interactive-shell

    ktfmt
    ktlint
  ];

}