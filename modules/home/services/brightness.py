from __future__ import annotations

from shared.lib import add_packages, user_systemd_unit


def apply(conf: dict, helpers) -> None:
    if not helpers.has_in("services", "brightnessctl"):
        return

    add_packages("brightnessctl")

    user_systemd_unit(
        helpers.username,
        "brightness.service",
        _brightness_unit(),
    )


def _brightness_unit() -> str:
    return """
[Unit]
Description=Set brightness on startup
After=graphical-session.target

[Service]
Type=oneshot
ExecStart=/usr/bin/brightnessctl set 50%
RemainAfterExit=true

[Install]
WantedBy=graphical-session.target
"""
