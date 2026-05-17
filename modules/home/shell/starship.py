from __future__ import annotations

from modules.home.shell._utils import dot_file
from shared.lib import add_packages


def apply(conf: dict, helpers) -> None:
    if not helpers.has_in("programs", "shell"):
        return

    add_packages("starship")

    dot_file(helpers.username, ".config/starship.toml")
