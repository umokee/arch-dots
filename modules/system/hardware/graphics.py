from __future__ import annotations

from shared.lib import add_packages


def apply(conf: dict, helpers) -> None:
    if not helpers.has_in("hardware", ["intel", "amd", "nvidia"]):
        return

    add_packages(
        "mesa",
        "libglvnd",
        "vulkan-loader",
        "vulkan-validation-layers",
        "libva-utils",
    )
