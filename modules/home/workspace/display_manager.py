from __future__ import annotations

from shared.lib import add_packages, system_file, systemd_unit


def apply(conf: dict, helpers) -> None:
    if not helpers.is_wm:
        return

    add_packages("ly")

    system_file(
        "/etc/ly/config.ini",
        _ly_config(),
    )

    systemd_unit(
        "ly.service",
        _ly_service(),
    )


def _ly_service() -> str:
    return """
[Unit]
Description=Ly display manager
Documentation=man:ly(1)
After=systemd-user-sessions.service getty@tty2.service plymouth-quit-wait.service
After=rc-local.service

Conflicts=getty@tty2.service
Conflicts=display-manager.service

[Service]
Type=simple
ExecStart=/usr/bin/ly
Restart=always
RestartSec=1

[Install]
Alias=display-manager.service
WantedBy=graphical.target
"""


def _ly_config() -> str:
    return """
# Managed by Decman

animation = matrix
bigclock = false
blank_box = true
clear_password = false
hide_borders = false
hide_key_hints = false
load = true
margin_box_h = 2
margin_box_v = 1
numlock = true
save = true
term_reset_cmd = /usr/bin/tput reset

# Sessions are read from /usr/share/wayland-sessions and /usr/share/xsessions.
"""
