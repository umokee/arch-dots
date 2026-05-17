from __future__ import annotations

from modules.home.workspace._utils import dot_dir
from shared.lib import add_aur, add_packages, user_systemd_unit


def apply(conf: dict, helpers) -> None:
    if not helpers.has_in("workspace", "quickshell"):
        return

    add_packages(
        "qt6-base",
        "qt6-declarative",
        "qt6-wayland",
        "qt6-svg",
    )

    add_aur("quickshell-git")

    dot_dir(helpers.username, ".config/quickshell")

    user_systemd_unit(
        helpers.username,
        "quickshell.service",
        _quickshell_unit(),
    )


def _quickshell_unit() -> str:
    return """
[Unit]
Description=Quickshell
PartOf=graphical-session.target
After=graphical-session.target

[Service]
ExecStart=/usr/bin/quickshell
Restart=on-failure
RestartSec=2

[Install]
WantedBy=graphical-session.target
"""
