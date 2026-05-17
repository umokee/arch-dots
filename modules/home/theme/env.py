from __future__ import annotations

from modules.home.theme._utils import generated_file


def apply(conf: dict, helpers) -> None:
    username = helpers.username

    generated_file(
        username,
        ".config/fish/conf.d/desktop-env.fish",
        _desktop_env(),
    )

    generated_file(
        username,
        ".config/environment.d/20-desktop.conf",
        _environment_d(),
    )


def _desktop_env() -> str:
    return """
# Managed by Decman

# Wayland
set -gx XDG_SESSION_TYPE wayland
set -gx GDK_BACKEND "wayland,x11"
set -gx QT_QPA_PLATFORM "wayland;xcb"
set -gx SDL_VIDEODRIVER wayland
set -gx CLUTTER_BACKEND wayland

# Qt
set -gx QT_QPA_PLATFORMTHEME qt6ct
set -gx QT_AUTO_SCREEN_SCALE_FACTOR 1

# Cursor
set -gx XCURSOR_THEME Adwaita
set -gx XCURSOR_SIZE 24

# Desktop identity
set -gx XDG_CURRENT_DESKTOP Hyprland
set -gx XDG_SESSION_DESKTOP Hyprland

# Electron / Chromium Wayland
set -gx NIXOS_OZONE_WL 1
set -gx ELECTRON_OZONE_PLATFORM_HINT auto

# Firefox Wayland
set -gx MOZ_ENABLE_WAYLAND 1
"""


def _environment_d() -> str:
    return """
# Managed by Decman

XDG_SESSION_TYPE=wayland
GDK_BACKEND=wayland,x11
QT_QPA_PLATFORM=wayland;xcb
QT_QPA_PLATFORMTHEME=qt6ct
SDL_VIDEODRIVER=wayland
CLUTTER_BACKEND=wayland

XCURSOR_THEME=Adwaita
XCURSOR_SIZE=24

XDG_CURRENT_DESKTOP=Hyprland
XDG_SESSION_DESKTOP=Hyprland

ELECTRON_OZONE_PLATFORM_HINT=auto
MOZ_ENABLE_WAYLAND=1
"""
