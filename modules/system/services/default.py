from __future__ import annotations

from modules.system.services.network import default as network
from modules.system.services.system import default as system


def apply(conf: dict, helpers) -> None:
    system.apply(conf, helpers)
    network.apply(conf, helpers)
