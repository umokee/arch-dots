from __future__ import annotations

from shared.lib import add_packages, enable_units


def apply(conf: dict, helpers) -> None:
    if not helpers.has_in("programs", "gaming"):
        return

    add_packages(
        "cachyos-gaming-meta",
        "steam",
        "gamescope",
        "gamemode",
        "lib32-gamemode",
        "mangohud",
        "lib32-mangohud",
        "protonup-qt",
        "lutris",
        "openrgb",
        "opentabletdriver",
        "ananicy-cpp",
    )

    enable_units("ananicy-cpp.service")
