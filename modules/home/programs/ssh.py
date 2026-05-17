from __future__ import annotations

from modules.home.programs.editors._utils import dot_file
from shared.lib import add_packages


def apply(conf: dict, helpers) -> None:
    if not helpers.has_in("programs", "ssh"):
        return

    add_packages("openssh")
    dot_file(
        helpers.username,
        ".ssh/config",
        mode=0o600,
    )
