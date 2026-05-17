from __future__ import annotations

from shared.lib import add_packages


def apply(conf: dict, helpers) -> None:
    if not helpers.has_in("services", "brightnessctl"):
        return

    add_packages("brightnessctl")
