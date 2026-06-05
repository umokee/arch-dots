function cleanup --description "Run Arch cleanup"
    if type -q arch-gc
        arch-gc $argv
    else
        echo "arch-gc not found"
        echo
        echo "== User cache size =="
        du -h -d 1 "$HOME/.cache" 2>/dev/null | sort -h

        echo
        echo "== Pacman orphans =="
        pacman -Qdtq 2>/dev/null

        echo
        echo "== Journal usage =="
        journalctl --disk-usage 2>/dev/null
    end
end
