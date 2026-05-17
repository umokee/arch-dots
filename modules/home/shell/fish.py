from __future__ import annotations

from modules.home.shell._utils import dot_dir
from shared.lib import add_packages


def apply(conf: dict, helpers) -> None:
    if not helpers.has_in("programs", "shell"):
        return

    add_packages(
        "fish",
        "fzf",
        "zoxide",
        "direnv",
    )

    dot_dir(helpers.username, ".config/fish")
