from __future__ import annotations

from shared.lib import add_aur, add_packages, system_file


def apply(conf: dict, helpers) -> None:
    if not helpers.has_in("programs", "browsers"):
        return

    username = helpers.username
    home = f"/home/{username}"

    add_packages(
        "firefox",
        "cascadia-code",
    )

    add_aur(
        "zen-browser-bin",
        "pywalfox-native",
    )

    if helpers.is_wm:
        system_file(
            f"{home}/.zen/native-messaging-hosts/pywalfox.json",
            _pywalfox_native_host(),
            owner=username,
        )

        system_file(
            f"{home}/.cache/wal/colors.json",
            _wal_colors(),
            owner=username,
        )


def _pywalfox_native_host() -> str:
    return """
{
  "name": "pywalfox",
  "description": "Pywalfox native messaging host",
  "path": "/usr/bin/pywalfox",
  "type": "stdio",
  "allowed_extensions": [
    "pywalfox@frewacom.org"
  ]
}
"""


def _wal_colors() -> str:
    return """
{
  "wallpaper": "",
  "alpha": "100",
  "colors": {
    "color0": "#090B17",
    "color1": "#f7768e",
    "color2": "#9ece6a",
    "color3": "#e0af68",
    "color4": "#7aa2f7",
    "color5": "#bb9af7",
    "color6": "#7dcfff",
    "color7": "#c0caf5",
    "color8": "#565f89",
    "color9": "#f7768e",
    "color10": "#9ece6a",
    "color11": "#e0af68",
    "color12": "#7aa2f7",
    "color13": "#bb9af7",
    "color14": "#7dcfff",
    "color15": "#c0caf5"
  }
}
"""
