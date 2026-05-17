from __future__ import annotations

from modules.system.services.network import firewall, sing_box, xray


def apply(conf: dict, helpers) -> None:
    firewall.apply(conf, helpers)
    xray.apply(conf, helpers)
    sing_box.apply(conf, helpers)
