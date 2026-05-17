from __future__ import annotations

from shared.lib import add_packages, enable_units, system_file


def apply(conf: dict, helpers) -> None:
    if not helpers.has_in("services", "virtual-machine"):
        return

    add_packages(
        "qemu-full",
        "virt-manager",
        "virt-viewer",
        "dnsmasq",
        "vde2",
        "openbsd-netcat",
        "libguestfs",
        "edk2-ovmf",
        "iproute2",
        "iptables-nft",
    )

    enable_units("libvirtd.service")

    system_file(
        "/etc/libvirt/qemu.conf.d/10-decman.conf",
        """
# Managed by Decman

user = "root"
group = "root"

dynamic_ownership = 1
remember_owner = 0
""",
    )
