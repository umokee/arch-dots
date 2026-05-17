from __future__ import annotations

from shared.lib import add_aur, add_packages, system_file


def apply(conf: dict, helpers) -> None:
    if not helpers.has_in("programs", "rclone"):
        return

    username = helpers.username
    home = f"/home/{username}"

    add_packages(
        "rclone",
        "rclone-browser",
    )

    add_aur("syncrclone")

    system_file(
        f"{home}/.syncrclone/nixos.py",
        _nixos_sync_config(home),
        owner=username,
    )

    system_file(
        f"{home}/.syncrclone/knastu.py",
        _knastu_sync_config(home),
        owner=username,
    )

    system_file(
        f"{home}/.local/bin/sync-folders",
        _sync_folders_script(home),
        mode=0o755,
        owner=username,
    )


def _common_filter_flags() -> str:
    return """
filter_flags = [
    '--exclude', '*.tmp',
    '--exclude', '*.temp',
    '--exclude', '*.cache',
    '--exclude', '*.log',
    '--exclude', '.git/**',
    '--exclude', '.git',
    '--exclude', 'node_modules/**',
    '--exclude', '__pycache__/**',
    '--exclude', '*.pyc',
    '--exclude', '.DS_Store',
    '--exclude', 'Thumbs.db',
    '--exclude', '~$*',
    '--exclude', '.~lock.*',
    '--exclude', '*.swp',
    '--exclude', '*.swo',
    '--exclude', '.syncrclone/**',
]
"""


def _sync_template(name: str, remote_a: str, remote_b: str) -> str:
    return f"""
# Managed by Decman

remoteA = "{remote_a}"
remoteB = "{remote_b}"

workdirA = None
workdirB = None

name = "{name}"

rclone_exe = "rclone"

{_common_filter_flags()}

rclone_flags = []
rclone_env = {{}}

rclone_flagsA = []
rclone_flagsB = []

compare = "mtime"
dt = 1.1

conflict_mode = "newer"
tag_conflict = False

reuse_hashesA = False
reuse_hashesB = False

always_get_mtime = True

backup = True
backup_with_copy = None
sync_backups = False

hash_fail_fallback = "mtime"

set_lock = True
action_threads = 4

cleanup_empty_dirsA = None
cleanup_empty_dirsB = None
avoid_relist = True

renamesA = "hash"
renamesB = "hash"

list_status_dt = 10

save_logs = True
local_log_dest = ""

pre_sync_shell = ""
post_sync_shell = ""

stop_on_shell_error = False
tempdir = None

_syncrclone_version = "20230310.0.BETA"
"""


def _nixos_sync_config(home: str) -> str:
    return _sync_template(
        name="nixos-sync",
        remote_a=f"{home}/nixos",
        remote_b="cloud:sync/nixos",
    )


def _knastu_sync_config(home: str) -> str:
    return _sync_template(
        name="knastu-sync",
        remote_a=f"{home}/knastu",
        remote_b="cloud:sync/knastu",
    )


def _sync_folders_script(home: str) -> str:
    return f"""
#!/usr/bin/env bash
set -euo pipefail

if ! command -v syncrclone >/dev/null 2>&1; then
  echo "syncrclone is not installed."
  echo "Install it manually later, for example via pipx/AUR."
  exit 1
fi

echo "=== Syncing knastu ==="
syncrclone "{home}/.syncrclone/knastu.py"

echo "=== Syncing nixos ==="
syncrclone "{home}/.syncrclone/nixos.py"

echo "=== Sync completed ==="
"""
