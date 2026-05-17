function cleanup --description "Simple user cleanup"
    echo "== User cache size =="
    du -h -d 1 "$HOME/.cache" 2>/dev/null | sort -h

    echo
    echo "== Pacman orphans =="
    pacman -Qdtq 2>/dev/null

    echo
    echo "== Journal usage =="
    journalctl --disk-usage 2>/dev/null
end
