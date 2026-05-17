from __future__ import annotations

from shared.lib import add_aur, add_packages


def apply(conf: dict, helpers) -> None:
    add_packages(
        "papirus-icon-theme",
        "adwaita-icon-theme",
    )

    add_aur("tela-circle-icon-theme-blue-git")
