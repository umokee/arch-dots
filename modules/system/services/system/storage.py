from __future__ import annotations

from shared.lib import add_packages, enable_units


def apply(conf: dict, helpers) -> None:
    if helpers.has_in("services", "fstrim"):
        add_packages("util-linux")
        enable_units("fstrim.timer")
