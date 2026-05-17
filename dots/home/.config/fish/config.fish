# ============================================================
# Fish main config
# Managed by Decman from dots/home/.config/fish/config.fish
# ============================================================

set fish_greeting

# Vi mode
fish_vi_key_bindings

set fish_cursor_default block
set fish_cursor_insert line
set fish_cursor_replace_one underscore
set fish_cursor_visual block

# History
set -g fish_history default
set -g fish_escape_delay_ms 10

# Colors
set -g fish_color_command 7aa2f7
set -g fish_color_param c0caf5
set -g fish_color_error f7768e
set -g fish_color_quote 9ece6a
set -g fish_color_redirection bb9af7
set -g fish_color_operator e0af68
set -g fish_color_comment 565f89
set -g fish_color_autosuggestion 565f89
set -g fish_color_valid_path normal

# Starship
if type -q starship
    starship init fish | source
end

# Zoxide
if type -q zoxide
    zoxide init fish | source
end

# Direnv
if type -q direnv
    direnv hook fish | source
end

# FZF
if type -q fzf
    set -gx FZF_DEFAULT_OPTS "
        --height=40%
        --layout=reverse
        --border
        --cycle
        --prompt='❯ '
        --pointer='▶'
        --marker='✓'
    "
end

# Ensure common dirs exist
mkdir -p "$HOME/.local/bin" "$HOME/.cache" "$HOME/.local/state" "$HOME/.local/share" 2>/dev/null

# Abbreviations
abbr --add c clear
abbr --add q exit
abbr --add .. "cd .."
abbr --add ... "cd ../.."
abbr --add .... "cd ../../.."

abbr --add gs "git status"
abbr --add ga "git add"
abbr --add gc "git commit"
abbr --add gp "git push"
abbr --add gl "git pull"
abbr --add gd "git diff"
abbr --add gds "git diff --staged"
abbr --add lg "git log --oneline --graph --decorate --all"

abbr --add v nvim
abbr --add sv "sudo nvim"
abbr --add ff fastfetch
abbr --add please sudo

# Arch / CachyOS
abbr --add pacs "pacman -Ss"
abbr --add paci "sudo pacman -S"
abbr --add pacu "sudo pacman -Syu"
abbr --add pacr "sudo pacman -Rns"
abbr --add pacq "pacman -Qs"
abbr --add paco "pacman -Qdtq"

# Decman
abbr --add dec "sudo DEC_HOST=desktop decman --skip aur --source ~/config/source.py --debug"
abbr --add decc "python -m compileall ~/config"
