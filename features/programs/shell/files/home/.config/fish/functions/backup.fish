function backup --description "Create timestamped backup copy"
    if test (count $argv) -eq 0
        echo "Usage: backup <file-or-directory>"
        return 1
    end

    set target $argv[1]

    if not test -e "$target"
        echo "backup: '$target' does not exist"
        return 1
    end

    set timestamp (date +%F-%H%M%S)
    set backup_name "$target.backup-$timestamp"

    cp -a "$target" "$backup_name"
    echo "Created: $backup_name"
end
