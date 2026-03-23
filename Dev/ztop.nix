{pkgs, ...}:

{
  imports = [
    # ./jupyter.nix
    # ./cpp_env.nix
    # ./android.nix
    ./git.nix
    ./overlays.nix
    ./nix-ld.nix
    ./Langs/ztop.nix

    ./Domain_Specific/UML.nix
    ./Domain_Specific/Docs.nix
    ./Domain_Specific/Pandoc.nix
    ./Domain_Specific/Big_Data.nix

    # Databases
    ./Domain_Specific/MySQL.nix
    ./Domain_Specific/PostgreSQL.nix

    ./IDEs/nvim.nix
    ./IDEs/vscodium.nix
  ];



  #--> direnv
  programs.direnv = {
    enable = true;
    loadInNixShell = true;
    nix-direnv.enable = true;
  };

  environment.systemPackages = with pkgs; [
    gource
    glslang

    zed-editor-fhs
  ];


}