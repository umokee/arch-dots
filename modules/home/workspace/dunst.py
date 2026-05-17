from __future__ import annotations

from modules.home.workspace._utils import dot_dir
from shared.lib import add_packages


def apply(conf: dict, helpers) -> None:
    if not helpers.is_wm:
        return

    add_packages(
        "dunst",
        "libnotify",
    )

    dot_dir(helpers.username, ".config/dunst")
