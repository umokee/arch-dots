from __future__ import annotations

from modules.home.theme._utils import dot_dir
from shared.lib import add_packages


def apply(conf: dict, helpers) -> None:
    add_packages(
        "qt5ct",
        "qt6ct",
        "qt5-wayland",
        "qt6-wayland",
        "adwaita-qt5",
        "adwaita-qt6",
    )

    dot_dir(helpers.username, ".config/qt5ct")
    dot_dir(helpers.username, ".config/qt6ct")
