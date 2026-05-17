from __future__ import annotations

from modules.system.base import default as base
from modules.system.hardware import default as hardware
from modules.system.services import default as services


def apply(conf: dict, helpers) -> None:
    base.apply(conf, helpers)
    hardware.apply(conf, helpers)
    services.apply(conf, helpers)
