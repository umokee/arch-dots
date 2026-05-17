from __future__ import annotations

from modules.home.theme._utils import generated_file
from shared.lib import add_aur


def apply(conf: dict, helpers) -> None:
    add_aur("posy-cursors")

    generated_file(
        helpers.username,
        ".icons/default/index.theme",
        "[Icon Theme]\nInherits=Posy_Cursor_Black\n",
    )
