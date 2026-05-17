from __future__ import annotations

from modules.home.theme._utils import dot_dir
from shared.lib import add_aur, add_packages


def apply(conf: dict, helpers) -> None:
    add_packages(
        "gtk3",
        "gtk4",
        "gsettings-desktop-schemas",
        "dconf",
        "nwg-look",
    )

    add_aur("adw-gtk-theme-git")

    dot_dir(helpers.username, ".config/gtk-3.0")
    dot_dir(helpers.username, ".config/gtk-4.0")
