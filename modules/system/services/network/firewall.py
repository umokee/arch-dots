from __future__ import annotations

from shared.lib import add_packages, enable_units


def apply(conf: dict, helpers) -> None:
    if not (
        helpers.has_in("services", "ufw") or helpers.has_in("services", "firewall")
    ):
        return

    add_packages("ufw")

    enable_units("ufw.service")
