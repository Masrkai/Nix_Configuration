{ pkgs, ... }:

{
   environment.systemPackages = with pkgs; [
    go

    gopls

    libcap

    go-outline
   ];
}