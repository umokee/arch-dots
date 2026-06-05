from __future__ import annotations

from pathlib import Path

from arch_config.appliers.files import config_home, write_home_or_system
from arch_config.model import MountItem
from arch_config.render.systemd_units import render_automount_unit, render_mount_unit


def apply_mount_unit(
    mount: MountItem,
    config: dict,
    *,
    automount: bool,
    dry_run: bool,
) -> None:
    home = config_home(config)

    if automount:
        target = Path("/etc/systemd/system") / mount.automount_unit
        content = render_automount_unit(mount)
    else:
        target = Path("/etc/systemd/system") / mount.mount_unit
        content = render_mount_unit(mount)

    write_home_or_system(
        target,
        content,
        "644",
        "root",
        "root",
        dry_run=dry_run,
        home=home,
    )


def apply_mount_units(
    mounts: list[MountItem],
    config: dict,
    *,
    dry_run: bool,
) -> None:
    for mount in mounts:
        apply_mount_unit(mount, config, automount=False, dry_run=dry_run)

        if mount.automount:
            apply_mount_unit(mount, config, automount=True, dry_run=dry_run)
