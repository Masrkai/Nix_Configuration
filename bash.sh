    # If not running interactively, don't do anything
    # [[ $- != *i* ]] && return

    #PS1='\[\e[36;1m\]>>>>>>Hi Masrkai!\[\e[0m\] \[\e[1m\]\w\n\[\e[38;5;160m\]\t\[\e[39m\][\[\e[36m\]\u\[\e[38;5;240m\]_\[\e[38;5;208m\]\H\[\e[39m\]]\$\[\e[0m\] '

    #--Functions
    wh() {
        sudo pkill dnsmasq ; cd $HOME/Programs/airgeddon && sudo bash airgeddon.sh ; cd
    }
    scode(){
        sudo codium --no-sandbox --user-data-dir=/home/masrkai/.config/VSCodium
    }
    garbage(){
        sudo nix-collect-garbage -d && nix-store --optimise && pip cache purge
    }
    gens(){
        sudo nix-env --list-generations --profile /nix/var/nix/profiles/system &&  echo "to remove Gens type:  sudo nix-env --profile /nix/var/nix/profiles/system --delete-generations <Gen's-Numbers>"
    }
    sudophone(){
        adb shell sh /sdcard/Android/data/moe.shizuku.privileged.api/start.sh
    }
    fixcode(){
        rm -rf ~/.config/VSCodium/GPUCache/
    }
    fixgit(){
        sudo chown -R $(whoami) .git
    }
    fix-arduino(){
        rm -rf ~/.config/arduino-ide/GPUCache/
    }
    fixbrave(){
        sudo rm -rf ~/.config/BraveSoftware/Brave-Browser/SingletonLock
    }
    fusb(){
         sudo chown masrkai  /dev/ttyUSB0
    }
    sec(){
        fwupdmgr get-devices && fwupdmgr refresh && fwupdmgr get-updates && fwupdmgr update
    }

    s() {
    if [[ $# == 0 ]]; then
        eval "sudo $(fc -ln -1)"
    else
        sudo "$@"
    fi }

    #! Extraction function
    # function extract {
    #  if [ $# -eq 0 ]; then
    #     echo "Usage: extract <path/file_name>.<zip|rar|bz2|gz|tar|tbz2|tgz|Z|7z|xz|ex|tar.bz2|tar.gz|tar.xz|.zlib|.cso|.zst>"
    #     echo "       extract <path/file_name_1.ext> [path/file_name_2.ext] [path/file_name_3.ext]"
    #  fi
    #     for n in "$@"; do
    #         if [ ! -f "$n" ]; then
    #             echo "'$n' - file doesn't exist"
    #             return 1
    #         fi

    #         case "''${n%,}" in
    #           *.cbt|*.tar.bz2|*.tar.gz|*.tar.xz|*.tbz2|*.tgz|*.txz|*.tar)
    #                        tar zxvf "$n"       ;;
    #           *.lzma)      unlzma ./"$n"      ;;
    #           *.bz2)       bunzip2 ./"$n"     ;;
    #           *.cbr|*.rar) unrar x -ad ./"$n" ;;
    #           *.gz)        gunzip ./"$n"      ;;
    #           *.cbz|*.epub|*.zip) unzip ./"$n"   ;;
    #           *.z)         uncompress ./"$n"  ;;
    #           *.7z|*.apk|*.arj|*.cab|*.cb7|*.chm|*.deb|*.iso|*.lzh|*.msi|*.pkg|*.rpm|*.udf|*.wim|*.xar|*.vhd)
    #                        7z x ./"$n"        ;;
    #           *.xz)        unxz ./"$n"        ;;
    #           *.exe)       cabextract ./"$n"  ;;
    #           *.cpio)      cpio -id < ./"$n"  ;;
    #           *.cba|*.ace) unace x ./"$n"     ;;
    #           *.zpaq)      zpaq x ./"$n"      ;;
    #           *.arc)       arc e ./"$n"       ;;
    #           *.cso)       ciso 0 ./"$n" ./"$n.iso" && \
    #                             extract "$n.iso" && \rm -f "$n" ;;
    #           *.zlib)      zlib-flate -uncompress < ./"$n" > ./"$n.tmp" && \
    #                             mv ./"$n.tmp" ./"''${n%.*zlib}" && rm -f "$n"   ;;
    #           *.dmg)
    #                       hdiutil mount ./"$n" -mountpoint "./$n.mounted" ;;
    #           *.tar.zst)  tar -I zstd -xvf ./"$n"  ;;
    #           *.zst)      zstd -d ./"$n"  ;;
    #           *)
    #                       echo "extract: '$n' - unknown archive method"
    #                       return 1
    #                       ;;
    #         esac
    #     done
    # }

SAVEIFS=$IFS
IFS="$(printf '\n\t')"

function extract {
 if [ $# -eq 0 ]; then
    echo "Usage: extract <path/file_name>.<zip|rar|bz2|gz|tar|tbz2|tgz|Z|7z|xz|ex|tar.bz2|tar.gz|tar.xz|.zlib|.cso|.zst>"
    echo "       extract <path/file_name_1.ext> [path/file_name_2.ext] [path/file_name_3.ext]"
    return 1
 fi
    for n in "$@"; do
        if [ ! -f "$n" ]; then
            echo "'$n' - file doesn't exist"
            continue
        fi

        case "${n%,}" in
            *.cbt|*.tar.bz2|*.tar.gz|*.tar.xz|*.tbz2|*.tgz|*.txz|*.tar)
                if [[ "$n" == *.tar.gz || "$n" == *.tgz ]]; then
                    tar zxvf "$n"
                else
                    tar xvf "$n"
                fi
                ;;
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
          *.cso)       ciso 0 ./"$n" ./"$n.iso" && extract "$n.iso" && rm -f "$n" ;;
          *.zlib)      zlib-flate -uncompress < ./"$n" > ./"$n.tmp" && \
                            mv ./"$n.tmp" ./"${n%.*zlib}" && rm -f "$n"   ;;
          *.dmg)       hdiutil mount ./"$n" -mountpoint "./$n.mounted" ;;
          *.tar.zst)   tar -I zstd -xvf ./"$n"  ;;
          *.zst)       zstd -d ./"$n"  ;;
          *)
                      echo "extract: '$n' - unknown archive method"
                      continue
                      ;;
        esac
    done
}

IFS=$SAVEIFS
