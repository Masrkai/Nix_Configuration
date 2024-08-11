{
#--> $BASH
programs.bash = {
  enableLsColors = true;
  enableCompletion = true;
  promptInit = '' PS1='\[\e[36;1m\]>>>>>>Hi Masrkai!\[\e[0m\] \[\e[1m\]\w\n\[\e[38;5;160m\]\t\[\e[39m\][\[\e[36m\]\u\[\e[38;5;240m\]_\[\e[38;5;208m\]\H\[\e[39m\]]\$\[\e[0m\] ' '';
  interactiveShellInit =  /* bash */ ''

    #bash configuration
      if [ -f /etc/profile ]; then
        . /etc/profile
      fi

      if [ -f ~/.bashrc ]; then
        . ~/.bashrc
      fi
  '';

  shellInit =
  /* bash */
  ''
    # If not running interactively, don't do anything
    [[ $- != *i* ]] && return

    PS1='\[\e[36;1m\]>>>>>>Hi Masrkai!\[\e[0m\] \[\e[1m\]\w\n\[\e[38;5;160m\]\t\[\e[39m\][\[\e[36m\]\u\[\e[38;5;240m\]_\[\e[38;5;208m\]\H\[\e[39m\]]\$\[\e[0m\] '

    #--Functions
    wh() {
        sudo pkill dnsmasq ; cd $HOME/Programs/airgeddon && sudo bash airgeddon.sh ; cd
    }
    scode(){
        sudo codium --no-sandbox --user-data-dir=/home/masrkai/.config/VSCodium
    }
    switch(){
        sudo nixos-rebuild switch
    }
    garbage(){
        nix-collect-garbage -d && nix-store --optimise && nix-env --delete-generations +2 && pip cache purge
    }
    gens(){
        sudo nix-env --list-generations --profile /nix/var/nix/profiles/system &&  echo "to remove Gens type:  sudo nix-env --profile /nix/var/nix/profiles/system --delete-generations <Gen's-Numbers>"
    }
    update(){
       sudo nix-channel --update && sudo nixos-rebuild switch --upgrade
    }
    sudophone(){
        adb shell sh /sdcard/Android/data/moe.shizuku.privileged.api/start.sh
    }
    fixcode(){
        rm -rf ~/.config/VSCodium/GPUCache/
    }
    fixbrave(){
        sudo rm -rf ~/.config/BraveSoftware/Brave-Browser/SingletonLock
    }
    wl(){
         sudo python3 /home/masrkai/Programs/Better-Evil-Limiter/evillimiter/evillimiter.py -f
    }
    fusb(){
         sudo chown masrkai  /dev/ttyUSB0
    }
    setupcpp(){
        /home/masrkai/Programs/Bash_Scripts/setup_cpp.sh
    }
    backup(){
       /home/masrkai/Programs/Bash_Scripts/Backup.sh
    }

    #! Extraction function
    function extract {
     if [ $# -eq 0 ]; then
        echo "Usage: extract <path/file_name>.<zip|rar|bz2|gz|tar|tbz2|tgz|Z|7z|xz|ex|tar.bz2|tar.gz|tar.xz|.zlib|.cso|.zst>"
        echo "       extract <path/file_name_1.ext> [path/file_name_2.ext] [path/file_name_3.ext]"
     fi
        for n in "$@"; do
            if [ ! -f "$n" ]; then
                echo "'$n' - file doesn't exist"
                return 1
            fi

            case "''${n%,}" in
              *.cbt|*.tar.bz2|*.tar.gz|*.tar.xz|*.tbz2|*.tgz|*.txz|*.tar)
                           tar zxvf "$n"       ;;
              *.lzma)      unlzma ./"$n"      ;;
              *.bz2)       bunzip2 ./"$n"     ;;
              *.cbr|*.rar) unrar x -ad ./"$n" ;;
              *.gz)        gunzip ./"$n"      ;;
              *.cbz|*.epub|*.zip) unzip ./"$n"   ;;
              *.z)         uncompress ./"$n"  ;;
              *.7z|*.apk|*.arj|*.cab|*.cb7|*.chm|*.deb|*.iso|*.lzh|*.msi|*.pkg|*.rpm|*.udf|*.wim|*.xar|*.vhd)
                           7z x ./"$n"        ;;
              *.xz)        unxz ./"$n"        ;;
              *.exe)       cabextract ./"$n"  ;;
              *.cpio)      cpio -id < ./"$n"  ;;
              *.cba|*.ace) unace x ./"$n"     ;;
              *.zpaq)      zpaq x ./"$n"      ;;
              *.arc)       arc e ./"$n"       ;;
              *.cso)       ciso 0 ./"$n" ./"$n.iso" && \
                                extract "$n.iso" && \rm -f "$n" ;;
              *.zlib)      zlib-flate -uncompress < ./"$n" > ./"$n.tmp" && \
                                mv ./"$n.tmp" ./"''${n%.*zlib}" && rm -f "$n"   ;;
              *.dmg)
                          hdiutil mount ./"$n" -mountpoint "./$n.mounted" ;;
              *.tar.zst)  tar -I zstd -xvf ./"$n"  ;;
              *.zst)      zstd -d ./"$n"  ;;
              *)
                          echo "extract: '$n' - unknown archive method"
                          return 1
                          ;;
            esac
        done
    }
  '';
  shellAliases = {
    cl = "clear";
    cp = "cp -vi";
    mv = "mv -vi";
    sudo = "sudo ";
    code = "codium";
    ff = "fastfetch";
    ip = "ip --color=auto";
    grep = "grep --color=auto";
    anime = "ani-cli -q 720 --dub";
    cpv = "rsync -avh --info=progress2";
    ascr = "scrcpy --no-audio -Sw --no-downsize-on-error";
    ls = "eza --color=always --long --git --icons=always";
    l = "eza  --color=always --long --tree --git --links -a --icons=always";
  };
};
}