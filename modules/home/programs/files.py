from __future__ import annotations

from shared.lib import add_packages


def apply(conf: dict, helpers) -> None:
    if not (
        helpers.has_in("services", "file-management")
        or helpers.has_in("programs", "files")
    ):
        return

    add_packages(
        "nemo",
        "dolphin",
        "nemo-fileroller",
        "gvfs",
        "gvfs-mtp",
        "gvfs-gphoto2",
        "gvfs-smb",
        "udisks2",
        "udiskie",
        "xarchiver",
        "file-roller",
    )
