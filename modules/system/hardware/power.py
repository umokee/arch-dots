from __future__ import annotations

from shared.lib import add_packages, enable_units, sysctl, system_file


def apply(conf: dict, helpers) -> None:
    if not helpers.has_in("hardware", "power"):
        return

    add_packages(
        "tlp",
        "tlp-rdw",
        "ethtool",
        "powertop",
    )

    if helpers.is_laptop:
        enable_units("tlp.service")

    sysctl(
        "70-power.conf",
        """
vm.laptop_mode = 0
""",
    )

    system_file(
        "/etc/tlp.conf.d/90-decman.conf",
        _tlp_config(helpers),
    )


def _tlp_config(helpers) -> str:
    if helpers.is_laptop:
        return """
# Managed by Decman

CPU_SCALING_GOVERNOR_ON_AC=performance
CPU_SCALING_GOVERNOR_ON_BAT=schedutil

CPU_ENERGY_PERF_POLICY_ON_AC=performance
CPU_ENERGY_PERF_POLICY_ON_BAT=balance_power

WIFI_PWR_ON_AC=off
WIFI_PWR_ON_BAT=on

USB_AUTOSUSPEND=1
"""

    return """
# Managed by Decman

CPU_SCALING_GOVERNOR_ON_AC=performance
WIFI_PWR_ON_AC=off
USB_AUTOSUSPEND=0
"""
