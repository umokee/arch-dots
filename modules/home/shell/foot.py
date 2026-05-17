from __future__ import annotations

from modules.home.shell._utils import dot_dir
from shared.lib import add_packages


def apply(conf: dict, helpers) -> None:
    if not helpers.has_in("programs", "terminal"):
        return

    add_packages("foot")

    dot_dir(helpers.username, ".config/foot")
