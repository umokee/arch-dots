function fish_prompt
    set -l last_status $status
    set -l cwd (prompt_pwd)
    set -l branch ""

    if command -q git
        set branch (git branch --show-current 2>/dev/null)
    end

    if test $last_status -ne 0
        set_color f7768e
        echo -n "[$last_status] "
    end

    set_color 7dcfff
    echo -n $cwd

    if test -n "$branch"
        set_color 565f89
        echo -n " git:$branch"
    end

    echo

    if fish_is_root_user
        set_color f7768e
        echo -n "# "
    else
        set_color 7aa2f7
        echo -n "> "
    end

    set_color normal
end
