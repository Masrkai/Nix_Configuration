{pkgs, ...}:

{
  imports = [
    # ./jupyter.nix
    # ./cpp_env.nix
    # ./android.nix
    ./git.nix
    ./overlays.nix
    ./vscodium.nix

    # Environments
    ./nix-ld.nix

    # Databases
    ./MySQL.nix
    ./PostgreSQL.nix
    ./nvim.nix
  ];



  #--> direnv
  programs.direnv = {
    enable = true;
    loadInNixShell = true;
    nix-direnv.enable = true;
  };

  environment.systemPackages = with pkgs; [
  ];


}