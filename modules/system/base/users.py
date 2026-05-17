from __future__ import annotations

from shared.lib import add_packages, systemd_unit


def apply(conf: dict, helpers) -> None:
    if not helpers.has_in("base", "users"):
        return

    add_packages("shadow")

    if not helpers.is_server or helpers.has_in("programs", "shell"):
        add_packages("fish")

    username = helpers.username
    groups = _groups(helpers)
    shell = "/usr/bin/bash" if helpers.is_server else "/usr/bin/fish"

    systemd_unit(
        "create-main-user.service",
        _create_user_unit(username, groups, shell),
    )


def _groups(helpers) -> list[str]:
    groups = [
        "wheel",
        "networkmanager",
        "input",
    ]

    if helpers.has_in("services", "docker"):
        groups += ["docker"]

    if helpers.has_in("hardware", "sound"):
        groups += ["audio"]

    if helpers.has_in("hardware", ["nvidia", "amd", "intel"]):
        groups += ["video", "render"]

    if helpers.has_in("services", "virtual-machine"):
        groups += ["libvirt"]

    return groups


def _create_user_unit(username: str, groups: list[str], shell: str) -> str:
    groups_str = ",".join(groups)

    return f"""
[Unit]
Description=Create main user if missing
After=local-fs.target

[Service]
Type=oneshot
ExecStart=/usr/bin/bash -lc 'id {username} >/dev/null 2>&1 || useradd -m -G {groups_str} -s {shell} {username}; usermod -aG {groups_str} {username} || true'
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
"""
