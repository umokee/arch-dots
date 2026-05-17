from __future__ import annotations

from modules.home.services import brightness, gammastep, kanshi


def apply(conf: dict, helpers) -> None:
    gammastep.apply(conf, helpers)
    brightness.apply(conf, helpers)
    kanshi.apply(conf, helpers)
