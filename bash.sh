

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
clearlogs(){
    sudo journalctl --rotate && sudo journalctl --vacuum-time=1s
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
fixkde(){
    sudo pkill -f plasmashell # Kill the current plasmashell process
    plasmashell --replace > /dev/null 2>&1 & disown
}



#--> yt-dlp
# Universal YouTube download function
download-youtube() {
    local url="$1"
    local resolution="${2:-1440}"  # Default to 1440p if no resolution is provided
    
    # Check if URL is provided
    if [ -z "$url" ]; then
        echo "Usage: download-youtube <url> [resolution]"
        echo "       download-playlist <url> [resolution]"
        echo "       download-video <url> [resolution]"
        echo "Example: download-youtube 'https://youtube.com/watch?v=...' 720"
        return 1
    fi
    
    # Determine output format based on function name used
    local output_format
    if [[ "${FUNCNAME[1]}" == "download-playlist" ]]; then
        output_format="%(playlist_index)s - %(title)s.%(ext)s"
    else
        output_format="%(title)s.%(ext)s"
    fi
    
    echo "Downloading with resolution: ${resolution}p"
    echo "Output format: $output_format"
    
    yt-dlp -f "bv[height<=${resolution}]+ba/b[height<=${resolution}]" \
           --sleep-interval 1 --max-sleep-interval 2 \
           --merge-output-format mp4 \
           --download-archive download_archive.txt \
           -o "$output_format" \
           "$url"
}

# Create aliases for the two function names
alias download-playlist='download-youtube'
alias download-video='download-youtube'



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


export HISTCONTROL="erasedups:ignoreboth"
export HISTFILE="$HOME/.bash_history"
export HISTORY_SIZE="1000000"



#-------------------------------------------------------------------------------------------------- TESTING
sectorcopy() {
    local extension="$1"
    local directory="${2:-.}"  # Default to current directory if not specified

    if [[ -z "$extension" ]]; then
        echo "Usage: sectorcopy <extension> [directory]" >&2
        return 1
    fi

    # Find files with the specified extension and process them
    find "$directory" -maxdepth 1 -type f -name "*$extension" -print0 | \
    sort -z | \
    while IFS= read -r -d '' file; do
        echo "$(basename "$file"):"
        echo
        echo '```'
        cat "$file"
        echo '```'
        echo
    done | wl-copy
}
#--------------------------------------------------------------------------------------------------! Convert all videos to MP4 with compatibility
# Function to convert video files to MP4 with baseline profile
convert_to_mp4() {
    # Check if input file is provided
    if [ $# -eq 0 ]; then
        echo "Usage: convert_to_mp4 <input_file>"
        echo "Example: convert_to_mp4 video.avi"
        return 1
    fi

    local input_file="$1"

    # Check if input file exists
    if [ ! -f "$input_file" ]; then
        echo "Error: File '$input_file' not found!"
        return 1
    fi

    # Extract filename without extension
    local filename=$(basename "$input_file")
    local name_without_ext="${filename%.*}"

    # Set output filename
    local output_file="${name_without_ext}.mp4"

    # Check if output file already exists
    if [ -f "$output_file" ]; then
        echo "Warning: Output file '$output_file' already exists!"
        read -p "Do you want to overwrite it? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Conversion cancelled."
            return 1
        fi
    fi

    echo "Converting '$input_file' to '$output_file'..."

   # Run the ffmpeg command (preserving baseline merits + new command benefits)
    ffmpeg -i "$input_file" \
           -c:v libx264 -profile:v baseline -level 3.0 -pix_fmt yuv420p \
           -vf "pad=ceil(iw/2)*2:ceil(ih/2)*2" \
           -c:a aac -ar 44100 -ac 2 \
           -movflags +faststart \
           "$output_file"

    # Check if conversion was successful
    if [ $? -eq 0 ]; then
        echo "✅ Conversion completed successfully: '$output_file'"
    else
        echo "❌ Conversion failed!"
        return 1
    fi
}
#--------------------------------------------------------------------------------------------------! Convert all Powerpoints to PDFs
convert_ppts_to_pdf() {
    local input_dir="${1:-.}"  # Default to current directory
    local output_dir="${2:-$input_dir}"  # Default to the input directory

    # Check if LibreOffice is installed
    if ! command -v libreoffice &> /dev/null; then
        echo "Error: LibreOffice is not installed" >&2
        return 1
    fi

    # Check if input directory exists
    if [ ! -d "$input_dir" ]; then
        echo "Error: Input directory '$input_dir' not found" >&2
        return 1
    fi

    # Create the output directory if it doesn't exist
    if [ ! -d "$output_dir" ]; then
        mkdir -p "$output_dir" || { echo "Error: Could not create output directory '$output_dir'"; return 1; }
    fi

    # Counter for converted files
    local converted=0

    # Use find with -exec to avoid subshell issues
    find "$input_dir" -type f \( -iname "*.ppt" -o -iname "*.pptx" \) -exec bash -c '
        file="$1"
        output_dir="$2"
        echo "Converting: $file"
        libreoffice --headless --convert-to pdf "$file" --outdir "$output_dir"
        if [ $? -eq 0 ]; then
            echo "Successfully converted: $file"
            return 0
        else
            echo "Failed to convert: $file"
            return 1
        fi
    ' _ {} "$output_dir" \; && ((converted++))

    echo "Conversion complete. Converted $converted files."
    return 0
}


#--------------------------------------------------------------------------------------------------! Compression function
SAVEIFS=$IFS
IFS="$(printf '\n\t')"

function compress {
    if [ $# -lt 3 ]; then
        echo "Usage: compress <compression_level> <format_flag> <path/file_name> [path/file_name_2] [path/file_name_3]"
        echo "Compression level: 1-9 for zip/7z/tar.lz, 1-9 for tar.gz"
        echo "Format flags: --zip, --tar.gz, --tar.lz, --7z, --tar.zst"
        return 1
    fi

    local level=$1
    local format_flag=$2
    shift 2
    local THREADS=$(nproc)

    # Progress bar display function
    progress_bar() {
        local percent=$1
        local filled=$((percent/2))
        printf "\r["
        printf "%${filled}s" | tr ' ' '='
        printf "%$((50-filled))s] %d%%" "" "$percent"
    }

    for n in "$@"; do
        if [ ! -f "$n" ] && [ ! -d "$n" ]; then
            echo "'$n' - file/directory doesn't exist"
            continue
        fi

        [[ "$level" =~ ^[0-9]+$ ]] || {
            echo "Invalid compression level. Must be a number."
            return 1
        }

        local filename=$(basename "$n")
        level=$((level > 9 ? 9 : level))

        echo "Compressing '$n' using $THREADS threads..."

        case "$format_flag" in

            "--7z")
                7z a -t7z -mx="$level" -mmt=on -bsp2 -bb0 "${filename}.7z" "$n"
                ;;

            "--zip")
                7z a -tzip -mx="$level" -mmt=on -bsp2 -bb1 "${filename}.zip" "$n"
                ;;

            "--tar.gz")
                local size=$(du -sb "$n" 2>/dev/null | awk '{print $1}')
                if [ -z "$size" ]; then
                    local pv_cmd="pv"
                else
                    local pv_cmd="pv -s $size"
                fi

                if command -v pigz >/dev/null; then
                    # Optimized pigz with block size and rsyncable
                    tar cf - "$n" | eval "$pv_cmd" | pigz -"$level" -p"$THREADS" --rsyncable -b 128 > "${filename}.tar.gz"
                else
                    echo "Notice: pigz not found, using single-threaded gzip"
                    tar cf - "$n" | eval "$pv_cmd" | gzip -"$level" > "${filename}.tar.gz"
                fi
                ;;

            "--tar.lz")
                if command -v pv >/dev/null && tarlz -h 2>&1 | grep -q -- '-f-'; then
                    local size=$(du -sb "$n" 2>/dev/null | awk '{print $1}')
                    [ -z "$size" ] && size=0
                    tarlz -c -n "$THREADS" --solid -"$level" -f- "$n" | pv -s "$size" > "${filename}.tar.lz"
                else
                    echo "Progress not available for tar.lz format"
                    tarlz -c -n "$THREADS" --solid -"$level" -f "${filename}.tar.lz" "$n"
                fi
                ;;

            "--tar.zst")
                local size=$(du -sb "$n" 2>/dev/null | awk '{print $1}')
                if [ -z "$size" ]; then
                    local pv_cmd="pv"
                else
                    local pv_cmd="pv -s $size"
                fi
                
                if command -v zstd >/dev/null; then
                    # Optimized zstd with adaptive mode
                    tar cf - "$n" | eval "$pv_cmd" | zstd -"$level" -T"$THREADS" --adapt > "${filename}.tar.zst"
                else
                    echo "Error: zstd not installed"
                    return 1
                fi
                ;;

            *)
                echo "Invalid format flag. Must be
                                                   --7z.
                                                   --zip,
                                                   --tar.gz, --tar.lz, --tar.zst
                "
                return 1
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





# export PS1='\[\e[36;1m\]>>>>>>Hi Masrkai!\[\e[0m\] \[\e[1m\]\w\n\e[38;5;160m\t\e[0m[\e[36m\u\e[38;5;240m_\e[38;5;208m\H\e[0m]\$ '
