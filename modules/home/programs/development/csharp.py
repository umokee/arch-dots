from __future__ import annotations

from shared.lib import add_packages, system_file


def apply(conf: dict, helpers) -> None:
    if not helpers.has_in("programs", "csharp-dev"):
        return

    username = helpers.username
    home = f"/home/{username}"

    add_packages(
        "dotnet-sdk",
        "dotnet-runtime",
        "aspnet-runtime",
        "fontconfig",
        "libx11",
        "libice",
        "libsm",
        "libxrandr",
        "libxcursor",
        "libxi",
        "wayland",
    )

    system_file(
        f"{home}/.config/direnv/lib/csharp-dev.sh",
        _direnv_csharp_lib(),
        owner=username,
    )


def _direnv_csharp_lib() -> str:
    return """
# Managed by Decman
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1

export GDK_BACKEND=wayland,x11
export DISPLAY="${DISPLAY:-:0}"
export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-0}"

export LD_LIBRARY_PATH="/usr/lib:${LD_LIBRARY_PATH:-}"
"""
