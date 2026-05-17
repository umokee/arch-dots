#!/usr/bin/env bash
set -euo pipefail

DOTS="${DOTS:-$HOME/dotfiles}"

echo "Applying home dotfiles from: $DOTS"

# ------------------------------------------------------------
# Directories
# ------------------------------------------------------------

mkdir -p "$HOME/.config/fish/conf.d"
mkdir -p "$HOME/.config/fish/functions"
mkdir -p "$HOME/.config/foot"
mkdir -p "$HOME/.config/starship"
mkdir -p "$HOME/.config/tmux"
mkdir -p "$HOME/.config/gtk-3.0"
mkdir -p "$HOME/.config/gtk-4.0"
mkdir -p "$HOME/.config/qt5ct"
mkdir -p "$HOME/.config/qt6ct"
mkdir -p "$HOME/.config/dunst"
mkdir -p "$HOME/.ssh"
mkdir -p "$HOME/.config/npm"
mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/.local/share"
mkdir -p "$HOME/.cache"
mkdir -p "$HOME/.local/state"

# ------------------------------------------------------------
# Fish
# ------------------------------------------------------------

cp "$DOTS/home/.config/fish/config.fish" \
  "$HOME/.config/fish/config.fish"

cp "$DOTS/home/.config/fish/conf.d/env.fish" \
  "$HOME/.config/fish/conf.d/env.fish"

cp "$DOTS/home/.config/fish/conf.d/aliases.fish" \
  "$HOME/.config/fish/conf.d/aliases.fish"

if [ -f "$DOTS/home/.config/fish/conf.d/desktop-env.fish" ]; then
  cp "$DOTS/home/.config/fish/conf.d/desktop-env.fish" \
    "$HOME/.config/fish/conf.d/desktop-env.fish"
fi

if compgen -G "$DOTS/home/.config/fish/functions/*.fish" > /dev/null; then
  cp "$DOTS/home/.config/fish/functions/"*.fish \
    "$HOME/.config/fish/functions/"
fi

# ------------------------------------------------------------
# Starship
# ------------------------------------------------------------

cp "$DOTS/home/.config/starship.toml" \
  "$HOME/.config/starship.toml"

# ------------------------------------------------------------
# Tmux
# ------------------------------------------------------------

cp "$DOTS/home/.config/tmux/tmux.conf" \
  "$HOME/.config/tmux/tmux.conf"

ln -sf "$HOME/.config/tmux/tmux.conf" "$HOME/.tmux.conf"

# ------------------------------------------------------------
# Git
# ------------------------------------------------------------

cp "$DOTS/home/.gitconfig" \
  "$HOME/.gitconfig"

# ------------------------------------------------------------
# SSH
# ------------------------------------------------------------

cp "$DOTS/home/.ssh/config" \
  "$HOME/.ssh/config"

chmod 700 "$HOME/.ssh"
chmod 600 "$HOME/.ssh/config"

# ------------------------------------------------------------
# Foot
# ------------------------------------------------------------

cp "$DOTS/home/.config/foot/foot.ini" \
  "$HOME/.config/foot/foot.ini"

# ------------------------------------------------------------
# GTK / Qt
# ------------------------------------------------------------

cp "$DOTS/home/.config/gtk-3.0/settings.ini" \
  "$HOME/.config/gtk-3.0/settings.ini"

cp "$DOTS/home/.config/gtk-4.0/settings.ini" \
  "$HOME/.config/gtk-4.0/settings.ini"

cp "$DOTS/home/.config/qt5ct/qt5ct.conf" \
  "$HOME/.config/qt5ct/qt5ct.conf"

cp "$DOTS/home/.config/qt6ct/qt6ct.conf" \
  "$HOME/.config/qt6ct/qt6ct.conf"

# ------------------------------------------------------------
# Dunst
# ------------------------------------------------------------

cp "$DOTS/home/.config/dunst/dunstrc" \
  "$HOME/.config/dunst/dunstrc"

# ------------------------------------------------------------
# npm XDG config
# ------------------------------------------------------------

cat > "$HOME/.config/npm/npmrc" << 'EOF'
prefix=${XDG_DATA_HOME}/npm
cache=${XDG_CACHE_HOME}/npm
init-module=${XDG_CONFIG_HOME}/npm/config/npm-init.js
logs-dir=${XDG_STATE_HOME}/npm/logs
EOF

echo "Done."
echo
echo "Reload shell:"
echo "  exec fish"
echo
echo "Reload dunst:"
echo "  pkill dunst; dunst &"
echo
echo "Check:"
echo "  notify-send 'Dunst test' 'Notifications are working'"
