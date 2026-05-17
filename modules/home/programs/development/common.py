from __future__ import annotations

from shared.lib import add_packages


def apply(conf: dict, helpers) -> None:
    add_packages(
        "gcc",
        "make",
        "cmake",
        "pkgconf",
        "gdb",
        "strace",
        "ltrace",
        "yq",
        "watchexec",
        "entr",
        "postgresql-libs",
        "sqlite",
        "sqlitebrowser",
    )
