from __future__ import annotations

from shared.lib import add_packages, system_file


def apply(conf: dict, helpers) -> None:
    if not helpers.has_in("base", "security"):
        return

    add_packages("polkit")

    system_file(
        "/etc/sudoers.d/00-user-policy",
        _sudoers(helpers),
        mode=0o440,
    )

    system_file(
        "/etc/security/limits.d/90-user-nice.conf",
        "* soft nice -20\n* hard nice -20\n",
    )


def _sudoers(helpers) -> str:
    if helpers.is_server:
        wheel_policy = "%wheel ALL=(ALL:ALL) NOPASSWD: ALL"
    else:
        wheel_policy = "%wheel ALL=(ALL:ALL) ALL"

    return f"""
Defaults timestamp_timeout=5
Defaults lecture=never
{wheel_policy}
"""
