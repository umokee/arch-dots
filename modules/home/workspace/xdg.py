from __future__ import annotations

from modules.home.workspace._utils import dot_file, generated_file
from shared.lib import add_packages


def apply(conf: dict, helpers) -> None:
    if not helpers.is_wm:
        return

    add_packages(
        "xdg-utils",
        "xdg-user-dirs",
    )

    dot_file(helpers.username, ".config/mimeapps.list")

    generated_file(
        helpers.username,
        ".local/share/applications/nvim.desktop",
        _nvim_desktop(),
    )

    generated_file(
        helpers.username,
        ".local/share/applications/pgadmin4.desktop",
        _pgadmin_desktop(),
    )


def _nvim_desktop() -> str:
    return """
[Desktop Entry]
Name=Neovim
Exec=foot -e nvim %F
Icon=nvim
Type=Application
Categories=Utility;TextEditor;
MimeType=text/plain;text/x-python;application/json;text/javascript;text/html;text/css;text/markdown;
"""


def _pgadmin_desktop() -> str:
    return """
[Desktop Entry]
Name=pgAdmin 4
Exec=pgadmin4
Icon=pgadmin4
Type=Application
Categories=Development;Database;
"""
