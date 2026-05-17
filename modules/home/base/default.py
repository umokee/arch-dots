from __future__ import annotations

from modules.home.base import env, packages


def apply(conf: dict, helpers) -> None:
    packages.apply(conf, helpers)
    env.apply(conf, helpers)
