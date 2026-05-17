from __future__ import annotations

from modules.home.programs.development import common, csharp, node, python


def apply(conf: dict, helpers) -> None:
    if not helpers.has_in("programs", "dev"):
        return

    common.apply(conf, helpers)
    python.apply(conf, helpers)
    node.apply(conf, helpers)
    csharp.apply(conf, helpers)
