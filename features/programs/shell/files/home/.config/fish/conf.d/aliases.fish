# Safer defaults
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -Iv'
alias mkdir='mkdir -pv'

# ls / tree
if type -q eza
    alias ls='eza --icons --group-directories-first'
    alias ll='eza -lah --icons --group-directories-first --git'
    alias la='eza -a --icons --group-directories-first'
    alias lt='eza --tree --icons --group-directories-first'
else
    alias ls='ls --color=auto'
    alias ll='ls -lah --color=auto'
    alias la='ls -A --color=auto'
end

# cat / grep
if type -q bat
    alias cat='bat --paging=never'
end

if type -q rg
    alias grep='rg'
end

# Editors
alias v='nvim'
alias vi='nvim'
alias vim='nvim'
alias svi='sudo nvim'

# System
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias path='echo $PATH | tr " " "\n"'
alias ports='ss -tulpn'
alias failed='systemctl --failed'
alias services='systemctl list-units --type=service --state=running'

# Pacman
alias pacs='pacman -Ss'
alias pacq='pacman -Qs'
alias paci='sudo pacman -S'
alias pacu='sudo pacman -Syu'
alias pacr='sudo pacman -Rns'
alias pacorphans='pacman -Qdtq'
alias pacclean='sudo paccache -rk2 && sudo paccache -ruk0'

# Yay
if type -q yay
    alias yayi='yay -S'
    alias yayu='yay -Syu'
    alias yayr='yay -Rns'
    alias yays='yay -Ss'
end

# Git
alias g='git'
alias gs='git status'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit'
alias gcm='git commit -m'
alias gp='git push'
alias gpl='git pull'
alias gd='git diff'
alias gds='git diff --staged'
alias gb='git branch'
alias gco='git checkout'
alias glog='git log --oneline --graph --decorate --all'

# Python
alias py='python'
alias pyvenv='python -m venv .venv'
alias activate='source .venv/bin/activate.fish'

# Node
alias ni='npm install'
alias nr='npm run'
alias nd='npm run dev'
alias nb='npm run build'

# archctl
alias ac='archctl -p desktop'
alias acd='archctl -p desktop diff'
alias acv='archctl -p desktop validate'
alias acg='archctl -p desktop generate'
alias acs='archctl -p desktop switch --aur'
alias acl='archctl -p desktop plan'
