from __future__ import annotations

from arch_config.model import SystemdItem
from arch_config.system.shell import run, run_root


def daemon_reload(
    *, has_system_units: bool, has_user_units: bool, dry_run: bool
) -> None:
    if has_system_units:
        run_root(["systemctl", "daemon-reload"], dry_run=dry_run)

    if has_user_units:
        run(["systemctl", "--user", "daemon-reload"], dry_run=dry_run)


def systemd_daemon_reload(scope: str, *, dry_run: bool) -> None:
    if scope == "system":
        run_root(["systemctl", "daemon-reload"], dry_run=dry_run)
    else:
        run(["systemctl", "--user", "daemon-reload"], dry_run=dry_run)


def apply_systemd_unit_action(
    item: SystemdItem,
    action: str,
    *,
    dry_run: bool,
) -> None:
    if action not in {"enable", "start"}:
        raise ValueError(f"unsupported systemd action: {action}")

    command = ["systemctl"] if item.scope == "system" else ["systemctl", "--user"]
    command = [*command, action, item.unit]

    if item.scope == "system":
        run_root(command, dry_run=dry_run)
    else:
        run(command, dry_run=dry_run)


def apply_systemd_units(
    units: list[SystemdItem],
    *,
    dry_run: bool,
) -> None:
    for item in units:
        if item.enable:
            apply_systemd_unit_action(item, "enable", dry_run=dry_run)

        if item.start:
            apply_systemd_unit_action(item, "start", dry_run=dry_run)
