{ config, lib, pkgs, modulesPath, ... }:

{
  services.ollama = {
    enable = true;
    acceleration = "cuda";
    host = "127.0.0.1";
    port = 11434;

    user = "ollama";
    group = "ollama";
  };
}