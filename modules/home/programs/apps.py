from __future__ import annotations

from shared.lib import add_aur, add_packages


def apply(conf: dict, helpers) -> None:
    if not helpers.is_wm:
        return

    add_packages(
        "obsidian",
        "chromium",
        "telegram-desktop",
        "libreoffice-fresh",
        "xorg-xlsclients",
        "transmission-gtk",
        "wev",
        "obs-studio",
        "webkit2gtk-4.1",
    )

    add_aur(
        "claude-code",
        "antigravity",
        "pgmodeler",
        "winboat",
        "spotify",
        "czkawka-gui",
        "mullvad-browser",
        "xmind",
        # "vial",
        "stretchly",
        "pgadmin4",
        "codex-bin",
    )

    if helpers.has_in("hardware", "sound"):
        add_packages(
            "pavucontrol",
            "easyeffects",
        )

    if helpers.has_in("hardware", "print"):
        add_packages(
            "simple-scan",
            "sane",
        )

    if helpers.has_in("services", "virtual-machine"):
        add_packages("virt-manager")

    if helpers.has_in("base", "network"):
        add_packages("network-manager-applet")
