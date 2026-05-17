from __future__ import annotations

from modules.home.workspace import (
    display_manager,
    dunst,
    hyprland,
    quickshell,
    tofi,
    wallpapers,
    xdg,
)


def apply(conf: dict, helpers) -> None:
    hyprland.apply(conf, helpers)
    quickshell.apply(conf, helpers)
    tofi.apply(conf, helpers)
    display_manager.apply(conf, helpers)
    dunst.apply(conf, helpers)
    wallpapers.apply(conf, helpers)
    xdg.apply(conf, helpers)
