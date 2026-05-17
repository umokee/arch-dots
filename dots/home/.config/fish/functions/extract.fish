function extract --description "Extract common archive formats"
    if test (count $argv) -eq 0
        echo "Usage: extract <archive>"
        return 1
    end

    set file $argv[1]

    if not test -f "$file"
        echo "extract: '$file' is not a file"
        return 1
    end

    switch "$file"
        case "*.tar.bz2"
            tar xjf "$file"
        case "*.tar.gz"
            tar xzf "$file"
        case "*.tar.xz"
            tar xJf "$file"
        case "*.tar.zst"
            tar --zstd -xf "$file"
        case "*.tar"
            tar xf "$file"
        case "*.tbz2"
            tar xjf "$file"
        case "*.tgz"
            tar xzf "$file"
        case "*.zip"
            unzip "$file"
        case "*.7z"
            7z x "$file"
        case "*.rar"
            unrar x "$file"
        case "*.gz"
            gunzip "$file"
        case "*.bz2"
            bunzip2 "$file"
        case "*"
            echo "extract: unknown archive type: $file"
            return 1
    end
end
