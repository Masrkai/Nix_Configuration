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
  ];


  environment.systemPackages = with pkgs; [
    zed-editor-fhs
  ];


}