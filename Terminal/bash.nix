{ config, pkgs, lib, ... }:

let
  systemFunctions = builtins.readFile ./Functions/bash.sh;

  nixos_specific  = builtins.readFile ./Functions/nixos_specific.sh;

  # Import shell script functions
  compress = builtins.readFile ./Functions/compress.sh;
  convert_ppts_to_pdf = builtins.readFile ./Functions/convert_ppts_to_pdf.sh;
  convert_to_mp4 = builtins.readFile ./Functions/convert_to_mp4.sh;
  journalctl = builtins.readFile ./Functions/journalctl.sh;
  sector_copy = builtins.readFile ./Functions/sector_copy.sh;
  yt_downloader = builtins.readFile ./Functions/yt_downlaoder.sh;
  fzf_bash_completion = builtins.readFile ./Functions/fzf-bash-completion.sh;
  sudo = builtins.readFile ./Functions/sudo.sh;

  ani_cli_batch = builtins.readFile ./Functions/ani-cli-batch.sh;
  sync_nixos_config = builtins.readFile ./Functions/sync_nixos_config.sh;

in

{
  imports = [
    ./starship.nix
  ];


  # Bash configuration
  programs.bash = {
    enableLsColors = lib.mkForce false;
    completion.enable = true;

    # Remove custom PS1 since Starship handles it
    interactiveShellInit = ''
      # if [ -f /etc/profile ]; then
      #   . /etc/profile
      # fi

      # if [ -f ~/.bashrc ]; then
      #   . ~/.bashrc
      # fi


      export ANI_CLI_PLAYER=haruna

      ${nixos_specific}

      ${systemFunctions}

      # Import shell script functions
      ${compress}
      ${convert_ppts_to_pdf}
      ${convert_to_mp4}
      ${journalctl}
      ${sector_copy}
      ${yt_downloader}
      ${sudo}
      ${sync_nixos_config}
      ${ani_cli_batch}


      # Source fzf-bash-completion
      ${fzf_bash_completion}
      bind -x '"\t": fzf_bash_completion'

      # Initialize Starship
      eval "$(${pkgs.starship}/bin/starship init bash)"


    '';

    shellAliases = {
      cl = "clear";
      sudo = "sudo ";
      code = "codium";
      ff = "fastfetch";
      ip = "ip --color=auto";
      anime = "ani-cli -q 720 --dub";
      ascr = "scrcpy --no-audio -Sw --no-downsize-on-error";
      fixnet = "sudo systemctl restart NetworkManager nftables stubby";

      # Verbose output when copying
      cpv = "rsync -avh --info=progress2";

      # Overwrite protection
      cp = "cp -vi ";
      mv = "mv -vi ";

      grep = "rg";
      # grep = "grep --color=auto";


      # Replacing List command with eza
      lss = "eza --color=always --group-directories-first --long --git --icons=always --total-size --links";
      ls  = "eza --color=always --group-directories-first --long --git --icons=always --links";
      la  = "eza --color=always --group-directories-first --long --git --icons=always --links -A";
      l   = "eza --color=always --group-directories-first --long --icons=always --links -a --tree";

      checkcpplib = "g++ -v -E -x c++ - </dev/null 2>&1 | grep -A 12 '#include <...> search starts here:'";
    };
  };

  environment.systemPackages = with pkgs; [
    viddy
    hwatch

    eza
    ripgrep
    nix-output-monitor
  ];
}