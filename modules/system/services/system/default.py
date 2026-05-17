from __future__ import annotations

from modules.system.services.system import (
    brightness,
    docker,
    fail2ban,
    kanata,
    openssh,
    postgresql,
    storage,
    virtual_machine,
)


def apply(conf: dict, helpers) -> None:
    postgresql.apply(conf, helpers)
    openssh.apply(conf, helpers)
    fail2ban.apply(conf, helpers)
    storage.apply(conf, helpers)
    virtual_machine.apply(conf, helpers)
    brightness.apply(conf, helpers)
    kanata.apply(conf, helpers)
    docker.apply(conf, helpers)
