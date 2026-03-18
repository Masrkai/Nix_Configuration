
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
