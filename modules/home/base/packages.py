from __future__ import annotations

from shared.lib import add_packages

USER_BASE_PACKAGES = [
    # Basic user CLI tools
    "less",
    "bat",
    "eza",
    "lsd",
    "btop",
    "inxi",
    "tree",
    "ripgrep",
    "fd",
    "jq",
    # Clipboard/media/user
    "wl-clipboard",
    "exfatprogs",
    "libva-utils",
    "ffmpeg",
    "ffmpegthumbnailer",
    # Archive tools
    "arj",
    "lrzip",
    "lzop",
    "7zip",
    "pbzip2",
    "pigz",
    "pixz",
    "unrar",
    "unzip",
    "zip",
    "brotli",
    "cpio",
]


def apply(conf: dict, helpers) -> None:
    add_packages(*USER_BASE_PACKAGES)
