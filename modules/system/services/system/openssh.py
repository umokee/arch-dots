from __future__ import annotations

from shared.lib import add_packages, enable_units, system_file


def apply(conf: dict, helpers) -> None:
    if not helpers.has_in("services", "openssh"):
        return

    add_packages("openssh")

    system_file(
        "/etc/ssh/sshd_config.d/10-decman.conf",
        _sshd_config(helpers),
    )

    enable_units("sshd.service")


def _sshd_config(helpers) -> str:
    username = helpers.username

    if helpers.is_server:
        permit_root = "prohibit-password"
    else:
        permit_root = "no"

    return f"""
# Managed by Decman

Port 22
Protocol 2

PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin {permit_root}
PubkeyAuthentication yes

X11Forwarding no
AllowUsers {username}

ClientAliveInterval 30
ClientAliveCountMax 3
"""
