from __future__ import annotations

from shared.lib import add_packages, user_systemd_unit


def apply(conf: dict, helpers) -> None:
    if not helpers.has_in("services", "gammastep"):
        return

    add_packages("gammastep")

    user_systemd_unit(
        helpers.username,
        "gammastep.service",
        _gammastep_unit(),
    )


def _gammastep_unit() -> str:
    return """
[Unit]
Description=Gammastep
PartOf=graphical-session.target
After=graphical-session.target

[Service]
ExecStart=/usr/bin/gammastep -l 43.1155:131.8855 -t 6000:3000
Restart=on-failure
RestartSec=3

[Install]
WantedBy=graphical-session.target
"""
