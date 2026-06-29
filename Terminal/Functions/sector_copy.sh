
sectorcopy() {
    local extension=""
    local directory="."
    local maxdepth=1

    while getopts "d:m:h" opt; do
        case $opt in
            d) directory="$OPTARG" ;;
            m) maxdepth="$OPTARG" ;;
            h) echo "Usage: sectorcopy [-d directory] [-m maxdepth] <extension>"; return 0 ;;
            *) return 1 ;;
        esac
    done
    shift $((OPTIND - 1))

    extension="$1"
    if [[ -z "$extension" ]]; then
        echo "Usage: sectorcopy [-d directory] [-m maxdepth] <extension>" >&2
        return 1
    fi

    find "$directory" -maxdepth "$maxdepth" -type f -name "*$extension" -print0 | \
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