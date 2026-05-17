from __future__ import annotations

from shared.lib import add_packages, enable_units


def apply(conf: dict, helpers) -> None:
    if not helpers.has_in("hardware", "print"):
        return

    add_packages(
        "cups",
        "gutenprint",
        "system-config-printer",
        "sane",
        "sane-airscan",
        "simple-scan",
    )

    enable_units("cups.socket")
