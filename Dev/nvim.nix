{pkgs, config, ...}:

{
  programs.neovim = {
    enable = true;
    defaultEditor = false;
    vimAlias = true;
    viAlias = true;
  } ;
}