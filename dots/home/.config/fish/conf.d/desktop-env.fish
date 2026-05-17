# Wayland
set -gx XDG_SESSION_TYPE wayland
set -gx GDK_BACKEND "wayland,x11"
set -gx QT_QPA_PLATFORM "wayland;xcb"
set -gx SDL_VIDEODRIVER wayland
set -gx CLUTTER_BACKEND wayland

# Qt theme config tools
set -gx QT_QPA_PLATFORMTHEME qt6ct
set -gx QT_AUTO_SCREEN_SCALE_FACTOR 1

# Cursor
set -gx XCURSOR_THEME Adwaita
set -gx XCURSOR_SIZE 24

# Icons / desktop files
set -gx XDG_CURRENT_DESKTOP Hyprland
set -gx XDG_SESSION_DESKTOP Hyprland

# Electron / Chromium Wayland hints
set -gx NIXOS_OZONE_WL 1
set -gx ELECTRON_OZONE_PLATFORM_HINT auto
