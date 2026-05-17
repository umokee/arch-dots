from __future__ import annotations

from shared.lib import add_packages, enable_units, system_file


def apply(conf: dict, helpers) -> None:
    if not helpers.has_in("base", "system"):
        return

    add_packages(
        "dbus-broker",
        "zram-generator",
    )

    enable_units(
        "getty@.service",
        "dbus-broker.service",
        "systemd-timesyncd.service",
        "systemd-userdbd.socket",
        "remote-fs.target",
    )

    system_file(
        "/etc/systemd/zram-generator.conf",
        _zram_config(helpers),
    )

    if helpers.is_server:
        system_file(
            "/etc/systemd/journald.conf.d/00-retention.conf",
            "[Journal]\nSystemMaxUse=500M\nMaxRetentionSec=1week\n",
        )


def _zram_config(helpers) -> str:
    size = "ram * 1.5" if helpers.is_server else "ram / 4"

    return f"""
# Managed by Decman

[zram0]
zram-size = {size}
compression-algorithm = zstd
swap-priority = 5
"""
