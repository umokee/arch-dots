from __future__ import annotations

from shared.lib import add_packages

BASE_PACKAGES = [
    # Arch/CachyOS base
    "base",
    "base-devel",
    "filesystem",
    "glibc",
    "linux-firmware",
    "pacman",
    "systemd",
    "systemd-sysvcompat",
    "sudo",
    # Boot
    "grub",
    "efibootmgr",
    "os-prober",
    "mkinitcpio",
    "mkinitcpio-busybox",
    "btrfs-progs",
    "dosfstools",
    "e2fsprogs",
    "cryptsetup",
    "lvm2",
    # Disk
    "smartmontools",
    # Base
    "bash",
    "git",
    "curl",
    "wget",
    "nano",
    "vim",
    "neovim",
    "coreutils",
    "util-linux",
    "shadow",
    "pciutils",
    "usbutils",
    "lsof",
    "gawk",
    # Archives
    "tar",
    "gzip",
    "unzip",
    "xz",
    "zstd",
    "lz4",
    "bzip2",
    "libarchive",
    "zip",
    "7zip",
    # Docs/Diagnostic
    "man-db",
    "man-pages",
    "texinfo",
    "rsync",
    "htop",
    "btop",
    "fastfetch",
    "ripgrep",
    "fd",
    "fzf",
    "jq",
    "tree",
    "pacman-contrib",
    "reflector",
    # Secrets
    "sops",
    "age",
]


NON_SERVER_EXTRA_PACKAGES = [
    "libnotify",
    "upower",
]


def apply(conf: dict, helpers) -> None:
    if not (helpers.has_in("base", "packages") or helpers.has_in("base", "system")):
        return

    add_packages(*BASE_PACKAGES)

    if not helpers.is_server:
        add_packages(*NON_SERVER_EXTRA_PACKAGES)
