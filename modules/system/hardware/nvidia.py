from __future__ import annotations

from shared.lib import add_packages, system_file


def apply(conf: dict, helpers) -> None:
    if not helpers.has_in("hardware", "nvidia"):
        return

    add_packages(
        "nvidia-utils",
        "nvidia-settings",
        "libva-nvidia-driver",
        "lib32-nvidia-utils",
    )

    system_file(
        "/etc/modprobe.d/nvidia.conf",
        """
# Managed by Decman
options nvidia_drm modeset=1 fbdev=1
blacklist nouveau
blacklist nova_core
""",
    )

    system_file(
        "/etc/environment.d/30-nvidia.conf",
        """
# Managed by Decman
LIBVA_DRIVER_NAME=nvidia
GBM_BACKEND=nvidia-drm
__GLX_VENDOR_LIBRARY_NAME=nvidia
""",
    )
