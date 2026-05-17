from __future__ import annotations

from shared.lib import add_packages, enable_units


def apply(conf: dict, helpers) -> None:
    if not helpers.has_in("hardware", "bluetooth"):
        return

    add_packages(
        "bluez",
        "bluez-utils",
        "blueman",
    )

    enable_units("bluetooth.service")
