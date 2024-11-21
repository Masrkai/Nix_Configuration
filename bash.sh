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
clearlogs(){
    sudo journalctl --rotate && sudo journalctl --vacuum-time=1s
}

#--> yt-dlp
# Function to download a playlist with a specified resolution
download-playlist() {
    local resolution="${2:-1440}"  # Default to 1440p if no resolution is provided
    yt-dlp -f "bv[height<=${resolution}]+ba/b[height<=${resolution}]" --sleep-interval 1 --max-sleep-interval 2 --merge-output-format mp4 --download-archive download_archive.txt "$1"
}

# Function to download a single video with a specified resolution
download-video() {
    local resolution="${2:-1440}"  # Default to 1440p if no resolution is provided
    yt-dlp -f "bv[height<=${resolution}]+ba/b[height<=${resolution}]" --sleep-interval 1 --max-sleep-interval 2 --merge-output-format mp4 --download-archive download_archive.txt "$1"
}

s() {
if [[ $# == 0 ]]; then
    eval "sudo $(fc -ln -1)"
else
    sudo "$@"
fi }

export FZF_DEFAULT_OPTS='
--color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9
--color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9
--color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6
--color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4'




#--------------------------------------------------------------------------------------------------! Extraction function
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



#------------------------------------------------------------------------------------------! Journald errors:
function journalctle() {
# Check for required tools
if ! command -v journalctl &> /dev/null; then
    echo "Error: journalctl is not available on your system."
    return 1
fi

if ! command -v bat &> /dev/null && ! command -v less &> /dev/null; then
    echo "Error: Neither 'bat' nor 'less' is installed. Install one to view highlighted output."
    return 1
fi

# Retrieve journald errors
local errors
errors=$(journalctl -p err -b | awk '!seen[$0]++') # Get errors from the current boot and remove duplicates

if [[ -z "$errors" ]]; then
    echo "No errors found in the journal for the current boot."
    return 0
fi

# Output with syntax highlighting
if command -v bat &> /dev/null; then
    echo "$errors" | bat --paging=always --language=log
else
    echo "$errors" | less -R
fi
}


#------------------------------------------------------------------------------------------! Journald warnings:
function journalctlw() {
# Check for required tools
if ! command -v journalctl &> /dev/null; then
    echo "Error: journalctl is not available on your system."
    return 1
fi

if ! command -v bat &> /dev/null && ! command -v less &> /dev/null; then
    echo "Error: Neither 'bat' nor 'less' is installed. Install one to view highlighted output."
    return 1
fi

# Retrieve journald warnings
local warnings
warnings=$(journalctl -p warning -b | awk '{message = $0; for (i=1; i<=4; i++) sub(/^[^ ]+ /, "", message); if (!seen[message]++) print message}')

if [[ -z "$warnings" ]]; then
    echo "No warnings found in the journal for the current boot."
    return 0
fi

# Output with syntax highlighting
if command -v bat &> /dev/null; then
    echo "$warnings" | bat --paging=always --language=log
else
    echo "$warnings" | less -R
fi
}
