from __future__ import annotations

from shared.lib import add_packages


def apply(conf: dict, helpers) -> None:
    if not helpers.has_in("programs", "appimage"):
        return

    add_packages(
        "fuse2",
        "desktop-file-utils",
        "shared-mime-info",
    )
