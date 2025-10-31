pandocmarkdowntopdf() {
    mkdir -p PDF || return 1

    shopt -s nullglob  # Ensure glob expands to nothing if no .md files
    local file
    for file in *.md; do
        pandoc "$file" \
            --pdf-engine=xelatex --embed-resources \
            -V geometry:margin=2cm \
            -V mainfont="Iosevka" \
            -V mathfont="Iosevka" \
            -V sansfont="Iosevka" \
            -V monofont="Iosevka" \
            -f markdown+smart  \
            -o "PDF/${file%.md}.pdf"
    done
}