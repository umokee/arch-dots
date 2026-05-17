set -gx DOTS "$HOME/dotfiles"

set -gx TERMINAL foot
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx BROWSER firefox

set -gx PAGER less
set -gx MANPAGER "nvim +Man!"

set -gx LESS "-R"
set -gx LESSHISTFILE "-"

# XDG base dirs
set -gx XDG_CONFIG_HOME "$HOME/.config"
set -gx XDG_DATA_HOME "$HOME/.local/share"
set -gx XDG_CACHE_HOME "$HOME/.cache"
set -gx XDG_STATE_HOME "$HOME/.local/state"

# Wayland / desktop defaults
set -gx XDG_SESSION_TYPE wayland
set -gx QT_QPA_PLATFORM "wayland;xcb"
set -gx GDK_BACKEND "wayland,x11"
set -gx SDL_VIDEODRIVER wayland
set -gx CLUTTER_BACKEND wayland

# Qt theme tools
set -gx QT_QPA_PLATFORMTHEME qt6ct

# Python
set -gx PYTHONPYCACHEPREFIX "$XDG_CACHE_HOME/python"
set -gx PYTHON_HISTORY "$XDG_STATE_HOME/python/history"

# Rust / Cargo
set -gx CARGO_HOME "$XDG_DATA_HOME/cargo"
set -gx RUSTUP_HOME "$XDG_DATA_HOME/rustup"

# Go
set -gx GOPATH "$XDG_DATA_HOME/go"

# Node / npm
set -gx NPM_CONFIG_USERCONFIG "$XDG_CONFIG_HOME/npm/npmrc"

# Local paths
fish_add_path "$HOME/.local/bin"
fish_add_path "$CARGO_HOME/bin"
fish_add_path "$GOPATH/bin"
