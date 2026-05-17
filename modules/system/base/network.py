from __future__ import annotations

from shared.lib import add_packages, enable_units, sysctl, system_file


def apply(conf: dict, helpers) -> None:
    if not helpers.has_in("base", "network"):
        return

    add_packages(
        "networkmanager",
        "wpa_supplicant",
        "iwd",
    )

    enable_units(
        "NetworkManager.service",
        "NetworkManager-dispatcher.service",
        "NetworkManager-wait-online.service",
    )

    system_file(
        "/etc/hostname",
        conf.get("hostname", "archlinux") + "\n",
    )

    system_file(
        "/etc/NetworkManager/conf.d/dns.conf",
        """
# Managed by Decman

[global-dns-domain-*]
servers=8.8.8.8,8.8.4.4,1.1.1.1
""",
    )

    sysctl(
        "80-network-tuning.conf",
        _network_sysctl(),
    )


def _network_sysctl() -> str:
    return """
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
vm.max_map_count = 16777216
"""
