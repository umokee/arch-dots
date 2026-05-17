from __future__ import annotations

from modules.home.programs.editors._utils import dot_dir
from shared.lib import add_packages


def apply(conf: dict, helpers) -> None:
    if not helpers.has_in("programs", "nvim"):
        return

    add_packages(
        "neovim",
        "tree-sitter",
    )

    dot_dir(
        helpers.username,
        ".config/nvim",
    )
