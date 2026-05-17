from __future__ import annotations

from shared.lib import add_packages


def apply(conf: dict, helpers) -> None:
    add_packages(
        "ttf-firacode-nerd",
        "ttf-hack-nerd",
        "ttf-jetbrains-mono-nerd",
        "ttf-font-awesome",
        "ttf-roboto",
        "ttf-inter",
        "ttf-montserrat",
        "ttf-opensans",
        "inter-font",
    )
