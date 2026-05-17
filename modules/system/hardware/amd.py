from __future__ import annotations

from shared.lib import add_packages, system_file


def apply(conf: dict, helpers) -> None:
    if not helpers.has_in("hardware", "amd"):
        return

    add_packages(
        "amd-ucode",
        "vulkan-radeon",
        "libva-mesa-driver",
        "mesa-vdpau",
        "vdpauinfo",
        "clinfo",
    )

    system_file(
        "/etc/environment.d/30-amd-graphics.conf",
        """
# Managed by Decman
MESA_LOADER_DRIVER_OVERRIDE=radeonsi
LIBVA_DRIVER_NAME=radeonsi
VDPAU_DRIVER=radeonsi
""",
    )

    if helpers.is_laptop:
        add_packages(
            "ryzenadj",
            "zenmonitor",
        )
