from __future__ import annotations

from shared.lib import add_packages, enable_units, system_file


def apply(conf: dict, helpers) -> None:
    if not helpers.has_in("services", "fail2ban"):
        return

    add_packages("fail2ban")

    system_file(
        "/etc/fail2ban/jail.d/sshd.local",
        """
# Managed by Decman

[sshd]
enabled = true
port = ssh
maxretry = 5
bantime = 1h
findtime = 10m
""",
    )

    enable_units("fail2ban.service")
