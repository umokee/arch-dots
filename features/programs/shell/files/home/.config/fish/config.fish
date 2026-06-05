set fish_greeting

fish_vi_key_bindings

set fish_cursor_default block
set fish_cursor_insert line
set fish_cursor_replace_one underscore
set fish_cursor_visual block

# History
set -g fish_history default
set -g fish_escape_delay_ms 10

# Colors
# set -g fish_color_normal c0caf5
# set -g fish_color_command 7aa2f7
# set -g fish_color_keyword bb9af7
# set -g fish_color_quote e0af68
# set -g fish_color_redirection 7dcfff
# set -g fish_color_end 9ece6a
# set -g fish_color_error f7768e
# set -g fish_color_param 7dcfff
# set -g fish_color_comment 565f89
# set -g fish_color_selection --background=364a82
# set -g fish_color_search_match --background=364a82
# set -g fish_color_operator 9ece6a
# set -g fish_color_escape bb9af7
# set -g fish_color_autosuggestion 565f89
# set -g fish_color_cancel f7768e
# set -g fish_color_valid_path --underline

# set -g fish_pager_color_progress 565f89
# set -g fish_pager_color_prefix 7aa2f7
# set -g fish_pager_color_completion c0caf5
# set -g fish_pager_color_description 565f89
# set -g fish_pager_color_selected_background --background=364a82

set -g fish_color_normal D7DAE0
set -g fish_color_command D7DAE0
set -g fish_color_keyword AAB2BF
set -g fish_color_quote 8FAF8F
set -g fish_color_redirection AAB2BF
set -g fish_color_end 8A9099
set -g fish_color_error C97B7B
set -g fish_color_param D7DAE0
set -g fish_color_comment 5D646F
set -g fish_color_selection --background=2E333D
set -g fish_color_search_match --background=2E333D
set -g fish_color_operator AAB2BF
set -g fish_color_escape AAB2BF
set -g fish_color_autosuggestion 5D646F
set -g fish_color_cancel C97B7B
set -g fish_color_valid_path --underline

set -g fish_pager_color_progress 5D646F
set -g fish_pager_color_prefix AAB2BF
set -g fish_pager_color_completion D7DAE0
set -g fish_pager_color_description 5D646F
set -g fish_pager_color_selected_background --background=2E333D

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
    set -gx FZF_DEFAULT_OPTS "\
        --height 40% --layout=reverse --border \
        --color=fg:#c0caf5,bg:#090B17,hl:#bb9af7 \
        --color=fg+:#c0caf5,bg+:#1a1b26,hl+:#7dcfff \
        --color=info:#7aa2f7,prompt:#7dcfff,pointer:#bb9af7 \
        --color=marker:#9ece6a,spinner:#bb9af7,header:#7aa2f7"
    set -gx FZF_CTRL_T_OPTS "--preview 'bat --color=always --style=numbers --line-range=:500 {} 2>/dev/null || ls -la {}'"
    set -gx FZF_ALT_C_OPTS "--preview 'eza --tree --level=2 --icons {} 2>/dev/null'"
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

# archctl
abbr --add ac "/home/user/arch-dots/scripts/archctl -p desktop"
abbr --add acd "/home/user/arch-dots/scripts/archctl -p desktop diff"
abbr --add acv "/home/user/arch-dots/scripts/archctl -p desktop validate"
abbr --add acg "/home/user/arch-dots/scripts/archctl -p desktop generate"
abbr --add acs "/home/user/arch-dots/scripts/archctl -p desktop switch --aur"
abbr --add acl "/home/user/arch-dots/scripts/archctl -p desktop plan"

bind \cf accept-autosuggestion
bind -M insert \cf accept-autosuggestion
