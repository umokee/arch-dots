from __future__ import annotations

from modules.system.base import (
    boot,
    cleanup,
    fonts,
    locale,
    network,
    packages,
    secrets,
    security,
    system,
    users,
)


def apply(conf: dict, helpers) -> None:
    packages.apply(conf, helpers)
    boot.apply(conf, helpers)
    system.apply(conf, helpers)
    security.apply(conf, helpers)
    locale.apply(conf, helpers)
    network.apply(conf, helpers)
    users.apply(conf, helpers)
    fonts.apply(conf, helpers)
    secrets.apply(conf, helpers)
    cleanup.apply(conf, helpers)
