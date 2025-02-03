{ config, lib, pkgs, modulesPath, ... }:

{
  services.ollama = {
    enable = true;
    acceleration = "cuda";

    port = 11434;
    host = "127.0.0.1";

    user = "ollama";
    group = "ollama";
  };

  services.tika = {
    enable = true;
    enableOcr = true;

    port = 9998;
    openFirewall = false;
    listenAddress = "127.0.0.1";
  };
}