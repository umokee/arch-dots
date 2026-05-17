from __future__ import annotations

from shared.lib import add_packages, enable_units, system_file


def apply(conf: dict, helpers) -> None:
    if not helpers.has_in("hardware", "sound"):
        return

    add_packages(
        "pipewire",
        "pipewire-pulse",
        "pipewire-alsa",
        "pipewire-jack",
        "wireplumber",
        "rtkit",
        "alsa-utils",
    )

    enable_units("rtkit-daemon.service")

    system_file(
        "/etc/modprobe.d/usb-audio.conf",
        """
# Managed by Decman
options snd_usb_audio autosuspend=-1
""",
    )

    system_file(
        "/etc/security/limits.d/95-audio.conf",
        """
# Managed by Decman
@audio - rtprio 95
@audio - memlock unlimited
""",
    )
