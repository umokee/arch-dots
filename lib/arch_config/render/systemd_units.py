from __future__ import annotations

from arch_config.model import MountItem


def render_mount_unit(mount: MountItem) -> str:
    opts = ",".join(mount.options)
    return f"""# Managed by archctl
[Unit]
Description=Mount {mount.what} at {mount.where}

[Mount]
What={mount.what}
Where={mount.where}
Type={mount.type}
Options={opts}
DirectoryMode={mount.directory_mode}

[Install]
WantedBy={mount.wanted_by}
"""


def render_automount_unit(mount: MountItem) -> str:
    return f"""# Managed by archctl
[Unit]
Description=Automount {mount.where}

[Automount]
Where={mount.where}
TimeoutIdleSec={mount.timeout_idle_sec}

[Install]
WantedBy={mount.wanted_by}
"""
