{ config, pkgs, ... }:

let
  systemFunctions = builtins.readFile ./bash.sh;

in

{

#--> $BASH
programs.bash = {
  enableLsColors = true;
  completion.enable = true;
  promptInit = '' PS1='\[\e[36;1m\]>>>>>>Hi Masrkai!\[\e[0m\] \[\e[1m\]\w\n\[\e[38;5;160m\]\t\[\e[39m\][\[\e[36m\]\u\[\e[38;5;240m\]_\[\e[38;5;208m\]\H\[\e[39m\]]\$\[\e[0m\] ' '';
  interactiveShellInit =  /* bash */ ''

    #bash configuration
      if [ -f /etc/profile ]; then
        . /etc/profile
      fi

      if [ -f ~/.bashrc ]; then
        . ~/.bashrc
      fi
    ${systemFunctions}
  '';


  shellAliases = {
    cl = "clear";
    sudo = "sudo ";
    code = "codium";
    ff = "fastfetch";
    ip = "ip --color=auto";
    grep = "grep --color=auto";
    anime = "ani-cli -q 720 --dub";
    ascr = "scrcpy --no-audio -Sw --no-downsize-on-error";
    fixnet = "sudo systemctl restart NetworkManager nftables stubby";

    #-> Verposed output when coppying
    cpv = "rsync -avh --info=progress2";

    #-> Overwrite protection
    cp = "cp -vi";
    mv = "mv -vi";

    #-> Replacing List command with eza @_@
    ls = "eza --color=always --long --git --icons=always";
    la = "eza  --color=always --long --tree --git --links -A --icons=always";
    l = "eza  --color=always --long --tree --git --links -a --icons=always";

    #-? NixOS Specific
    switch =  "sudo -v && sudo bash -c 'nixos-rebuild switch --show-trace 2>&1' | nom";
    update = "sudo nix-channel --update && sudo nixos-rebuild switch --upgrade --show-trace 2>&1 |&  nom";
    checkcpplib = "g++ -v -E -x c++ - </dev/null 2>&1 | grep -A 12 '#include <...> search starts here:'";
  };
};
}