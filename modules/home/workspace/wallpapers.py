from __future__ import annotations

from modules.home.workspace._utils import dot_dir
from shared.lib import add_packages, user_systemd_unit


def apply(conf: dict, helpers) -> None:
    if not helpers.has_in("workspace", "wallpapers"):
        return

    add_packages("swaybg")

    dot_dir(helpers.username, "Pictures/wallpapers")

    user_systemd_unit(
        helpers.username,
        "swaybg-daemon.service",
        _swaybg_unit(conf.get("wallpaper_name", "backyard")),
    )


def _swaybg_unit(wallpaper_name: str) -> str:
    filename = _wallpaper_file(wallpaper_name)

    return f"""
[Unit]
Description=Swaybg Wallpaper Daemon
After=graphical-session.target
PartOf=graphical-session.target

[Service]
ExecStart=/usr/bin/swaybg -i %h/Pictures/wallpapers/{filename} -m fill
Restart=on-failure
RestartSec=3

[Install]
WantedBy=graphical-session.target
"""


def _wallpaper_file(wallpaper_name: str) -> str:
    mapping = {
        "backyard": "Backyard.png",
    }
    return mapping.get(wallpaper_name, "Backyard.png")
