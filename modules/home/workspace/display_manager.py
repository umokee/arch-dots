from __future__ import annotations

from shared.lib import enable_units, system_file


def apply(conf: dict, helpers) -> None:
    if not helpers.is_wm:
        return

    enable_units("ly.service")

    system_file(
        "/etc/ly/config.ini",
        _ly_config(),
    )


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
