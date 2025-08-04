#!/usr/bin/env bash

SAVEIFS=$IFS
IFS="$(printf '\n\t')"

# Function to extract various archive formats
# Usage: extract [-d <output_directory>] <archive_file1> [<archive_file2> ...]
function extract {
    local dest_dir="."  # Default destination is current directory
    local archives=()   # Array to hold archive file names
    local opt

    # Parse command-line options
    while getopts ":d:" opt; do
        case $opt in
            d)
                dest_dir="$OPTARG"
                # Ensure destination directory exists
                if [[ ! -d "$dest_dir" ]]; then
                    echo "extract: Destination directory '$dest_dir' does not exist. Creating it."
                    mkdir -p "$dest_dir" || { echo "extract: Failed to create directory '$dest_dir'"; return 1; }
                fi
                 # Make path absolute for tools that might need it (like 7z)
                if [[ "$dest_dir" != /* ]]; then
                     dest_dir="$PWD/$dest_dir"
                fi
                ;;
            \?)
                echo "extract: Invalid option -$OPTARG" >&2
                echo "Usage: extract [-d <output_directory>] <path/file_name.ext> ..." >&2
                return 1
                ;;
            :)
                echo "extract: Option -$OPTARG requires an argument." >&2
                echo "Usage: extract [-d <output_directory>] <path/file_name.ext> ..." >&2
                return 1
                ;;
        esac
    done
    shift $((OPTIND - 1))

    # Check if any archive files were provided after options
    if [ $# -eq 0 ]; then
        echo "Usage: extract [-d <output_directory>] <path/file_name>.<zip|rar|bz2|gz|tar|tbz2|tgz|Z|7z|xz|ex|tar.bz2|tar.gz|tar.xz|.zlib|.cso|.zst|dmg|...>"
        echo "       extract [-d <output_directory>] <path/file_name_1.ext> [path/file_name_2.ext] ..."
        return 1
    fi

    # Process each provided file argument
    for n in "$@"; do
        # Check if the file exists
        if [ ! -f "$n" ]; then
            echo "extract: '$n' - file doesn't exist"
            continue
        fi

        # Inform user about the operation
        echo "extract: Attempting to extract '$n' to '$dest_dir'..."

        # Determine archive type and use appropriate extraction command with destination and progress options
        case "${n%,}" in
            # --- Tar-based archives ---
            *.cbt|*.tar.bz2|*.tar.gz|*.tar.xz|*.tbz2|*.tgz|*.txz|*.tar)
                 # Use --checkpoint for basic progress indication
                 if [[ "$n" == *.tar.gz || "$n" == *.tgz ]]; then
                    tar --checkpoint=1000 --checkpoint-action=dot -zxvf "$n" -C "$dest_dir"
                 else
                    tar --checkpoint=1000 --checkpoint-action=dot -xvf "$n" -C "$dest_dir"
                 fi
                 ;;
            # --- Other single-file compression ---
            *.lzma)      unlzma -c "./$n" > "$dest_dir/${n%.lzma}" ;;
            *.bz2)       bunzip2 -c "./$n" > "$dest_dir/${n%.bz2}" ;;
            *.gz)        gunzip -c "./$n" > "$dest_dir/${n%.gz}" ;;
            # --- RAR archives ---
            *.cbr|*.rar)
                 # unrar has built-in progress indication
                 unrar x "./$n" "$dest_dir/" ;;
            # --- ZIP archives ---
            *.cbz|*.epub|*.zip)
                 # unzip -v provides verbose output (list of files)
                 unzip -q -o "./$n" -d "$dest_dir" ;; # -q for quieter, -o to overwrite
            # --- Z compression ---
            *.z)         uncompress -c "./$n" > "$dest_dir/${n%.z}" ;;
            # --- 7-Zip and related formats ---
            *.7z|*.apk|*.arj|*.cab|*.cb7|*.chm|*.deb|*.iso|*.lzh|*.msi|*.pkg|*.rpm|*.udf|*.wim|*.xar|*.vhd)
                 # 7z has built-in progress indication (-bsp1), -o specifies output dir
                 7z x -bsp1 -y -o"$dest_dir" "./$n" ;;
            # --- XZ compression ---
            *.xz)        unxz -c "./$n" > "$dest_dir/${n%.xz}" ;;
            # --- EXE (Cabinet) archives ---
            *.exe)
                 # cabextract might show some output, -F forces overwrite if needed
                 cabextract -F -d "$dest_dir" "./$n" ;;
            # --- CPIO archives ---
            *.cpio)
                 # Extracting CPIO requires being in the target directory or piping
                 (cd "$dest_dir" && cpio -idmv < "../$n") ;; # -v for verbose
            # --- ACE archives ---
            *.cba|*.ace)
                 # unace might show progress
                 unace x -y "./$n" "$dest_dir/" ;; # -y to overwrite without asking
            # --- ZPAQ archives ---
            *.zpaq)
                 # zpaq shows progress by default
                 zpaq x "./$n" "$dest_dir/" ;;
            # --- ARC archives ---
            *.arc)
                 # arc e shows progress
                 arc e "./$n" "$dest_dir/" ;;
            # --- CSO archives (converts to ISO first) ---
            *.cso)
                 # Extract to temp location within dest_dir, then re-extract ISO, then clean up
                 local temp_iso="$dest_dir/${n%.cso}.iso"
                 ciso 0 "./$n" "$temp_iso" && extract -d "$dest_dir" "$temp_iso" && rm -f "$temp_iso" ;;
            # --- ZLIB compressed files ---
            *.zlib)
                 # Decompress and redirect output
                 zlib-flate -uncompress < "./$n" > "$dest_dir/${n%.zlib}" ;;
            # --- DMG disk images (macOS specific) ---
            *.dmg)
                 # Mounting doesn't extract, but specify mount point
                 # Note: This requires user interaction to unmount later
                 echo "extract: Mounting DMG '$n' to '$dest_dir/$n.mounted'. You may need to unmount it manually later."
                 hdiutil attach "./$n" -mountpoint "$dest_dir/$n.mounted" ;;
            # --- Zstandard archives ---
            *.tar.zst)
                 # Use tar with zstd for decompression, specify directory
                 tar -I zstd --checkpoint=1000 --checkpoint-action=dot -xvf "./$n" -C "$dest_dir" ;;
            *.zst)
                 # Decompress single .zst file, specify output
                 zstd -d "./$n" -o "$dest_dir/${n%.zst}" ;;
            # --- Unknown archive type ---
            *)
                 echo "extract: '$n' - unknown archive method"
                 continue
                 ;;
        esac

        # Check the exit status of the last command (the extraction command)
        if [ $? -ne 0 ]; then
            echo "extract: Failed to extract '$n'"
        else
            echo "extract: Successfully extracted '$n' to '$dest_dir'"
        fi
    done
}

# Restore IFS
IFS=$SAVEIFS

# Call the extract function with all arguments passed to the script
extract "$@"