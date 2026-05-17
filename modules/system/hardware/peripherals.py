from __future__ import annotations

from shared.lib import add_packages, systemd_unit


def apply(conf: dict, helpers) -> None:
    if not helpers.has_in("hardware", "keyboard-mouse"):
        return

    add_packages(
        "libinput",
        "xorg-xinput",
        "wev",
    )


