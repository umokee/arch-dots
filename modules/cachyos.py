from __future__ import annotations

from shared.lib import add_packages, system_file


def _pacman_conf(target: str, include_base: bool) -> str:
    repo = {
        "generic": ("[cachyos]\nInclude = /etc/pacman.d/cachyos-mirrorlist\n"),
        "v3": (
            "[cachyos-v3]\n"
            "Include = /etc/pacman.d/cachyos-v3-mirrorlist\n\n"
            "[cachyos-core-v3]\n"
            "Include = /etc/pacman.d/cachyos-v3-mirrorlist\n\n"
            "[cachyos-extra-v3]\n"
            "Include = /etc/pacman.d/cachyos-v3-mirrorlist\n"
        ),
        "v4": (
            "[cachyos-v4]\n"
            "Include = /etc/pacman.d/cachyos-v4-mirrorlist\n\n"
            "[cachyos-core-v4]\n"
            "Include = /etc/pacman.d/cachyos-v4-mirrorlist\n\n"
            "[cachyos-extra-v4]\n"
            "Include = /etc/pacman.d/cachyos-v4-mirrorlist\n"
        ),
        "znver4": (
            "[cachyos-znver4]\n"
            "Include = /etc/pacman.d/cachyos-v4-mirrorlist\n\n"
            "[cachyos-core-znver4]\n"
            "Include = /etc/pacman.d/cachyos-v4-mirrorlist\n\n"
            "[cachyos-extra-znver4]\n"
            "Include = /etc/pacman.d/cachyos-v4-mirrorlist\n"
        ),
        "znver5": (
            "[cachyos-znver5]\n"
            "Include = /etc/pacman.d/cachyos-v4-mirrorlist\n\n"
            "[cachyos-core-znver5]\n"
            "Include = /etc/pacman.d/cachyos-v4-mirrorlist\n\n"
            "[cachyos-extra-znver5]\n"
            "Include = /etc/pacman.d/cachyos-v4-mirrorlist\n"
        ),
    }[target]

    if include_base and target != "generic":
        repo += "\n[cachyos]\nInclude = /etc/pacman.d/cachyos-mirrorlist\n"

    return (
        f"""
[options]
HoldPkg     = pacman glibc
Architecture = auto
CheckSpace
ParallelDownloads = 10
Color
ILoveCandy
VerbosePkgLists
SigLevel    = Required DatabaseOptional
LocalFileSigLevel = Optional

# CachyOS repos above Arch repos.
{repo}
[core]
Include = /etc/pacman.d/mirrorlist

[extra]
Include = /etc/pacman.d/mirrorlist

[multilib]
Include = /etc/pacman.d/mirrorlist
""".strip()
        + "\n"
    )


def apply(conf: dict, helpers) -> None:
    c = conf.get("cachyos", {})

    add_packages(
        "cachyos-keyring",
        "cachyos-mirrorlist",
        "cachyos-v3-mirrorlist",
        "cachyos-v4-mirrorlist",
        "cachyos-rate-mirrors",
    )

    kernel = c.get("kernel", "linux-cachyos")
    kernel_headers = c.get("kernel_headers", f"{kernel}-headers")

    add_packages(kernel, kernel_headers)

    for package in c.get("kernel_extra_packages", []):
        add_packages(package)

    if c.get("install_settings", True):
        add_packages(
            "cachyos-hooks",
            "cachyos-settings",
            "cachyos-micro-settings",
        )

    example = _pacman_conf(
        c.get("repo_target", "v4"),
        c.get("include_base_repo", True),
    )

    system_file("/etc/pacman.conf.decman-cachyos-example", example)

    if c.get("manage_pacman_conf", False):
        system_file("/etc/pacman.conf", example)
