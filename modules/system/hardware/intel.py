from __future__ import annotations

from shared.lib import add_packages, system_file


def apply(conf: dict, helpers) -> None:
    if not helpers.has_in("hardware", "intel"):
        return

    add_packages(
        "intel-ucode",
        "vulkan-intel",
        "intel-media-driver",
        "libva-intel-driver",
        "libva-vdpau-driver",
        "libvdpau-va-gl",
        "intel-gpu-tools",
    )

    if not helpers.has_nvidia:
        system_file(
            "/etc/environment.d/30-intel-graphics.conf",
            """
# Managed by Decman
LIBVA_DRIVER_NAME=iHD
""",
        )
