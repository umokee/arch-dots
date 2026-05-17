from __future__ import annotations

from shared.lib import add_packages, sysctl, system_file


def apply(conf: dict, helpers) -> None:
    if not helpers.has_in("base", "boot"):
        return

    add_packages(
        "grub",
        "efibootmgr",
        "os-prober",
        "btrfs-progs",
        "dosfstools",
        "e2fsprogs",
        "cryptsetup",
        "lvm2",
        "mkinitcpio",
        "mkinitcpio-busybox",
    )

    system_file(
        "/etc/udev/rules.d/60-ioscheduler.rules",
        'ACTION=="add|change", SUBSYSTEM=="block", ATTR{queue/scheduler}="bfq"\n',
    )

    sysctl(
        "90-user-boot.conf",
        """
kernel.split_lock_mitigate = 0
vm.swappiness = 10
vm.vfs_cache_pressure = 50
vm.dirty_bytes = 268435456
vm.max_map_count = 16777216
vm.dirty_background_bytes = 67108864
vm.dirty_writeback_centisecs = 1500
kernel.nmi_watchdog = 0
kernel.unprivileged_userns_clone = 1
kernel.printk = 3 3 3 3
kernel.kptr_restrict = 2
kernel.kexec_load_disabled = 1
""",
    )

    system_file(
        "/etc/default/grub",
        _grub_config(helpers),
    )


def _kernel_params(helpers) -> str:
    params = [
        "quiet",
        "splash",
        "nosplit_lock_mitigate",
    ]

    if helpers.has_in("hardware", "amd"):
        params += [
            "amd_pstate=active",
            "clearcpuid=514",
        ]

    if helpers.has_in("hardware", "nvidia"):
        params += [
            "nvidia-drm.modeset=1",
        ]

    return " ".join(params)


def _grub_config(helpers) -> str:
    return f"""
# Managed by Decman

GRUB_DEFAULT=0
GRUB_TIMEOUT=3
GRUB_DISTRIBUTOR="Arch"
GRUB_CMDLINE_LINUX_DEFAULT="{_kernel_params(helpers)}"
GRUB_CMDLINE_LINUX=""

GRUB_PRELOAD_MODULES="part_gpt part_msdos"
GRUB_TERMINAL_INPUT=console
GRUB_GFXMODE=auto
GRUB_GFXPAYLOAD_LINUX=keep

GRUB_DISABLE_RECOVERY=true
GRUB_DISABLE_SUBMENU=true
GRUB_DISABLE_OS_PROBER=false
"""
