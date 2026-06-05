from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path
from typing import Any


@dataclass(frozen=True)
class FileItem:
    feature: str
    source: str
    source_abs: Path
    target: str
    target_abs: Path
    mode: str
    type: str = "file"
    owner: str = "root"
    group: str = "root"
    permissions: str = "644"
    executable: bool = False

    @property
    def name(self) -> str:
        return self.target.replace("/", "__").replace("~", "home")


@dataclass(frozen=True)
class DirItem:
    target: str
    target_abs: Path
    permissions: str = "755"


@dataclass(frozen=True)
class LinkItem:
    source: str
    source_abs: Path
    target: str
    target_abs: Path


@dataclass(frozen=True)
class SystemdItem:
    feature: str
    scope: str
    unit: str
    enable: bool = True
    start: bool = True


@dataclass(frozen=True)
class HookItem:
    feature: str
    name: str
    script: str
    script_abs: str
    run: str = "post"
    kind: str = "external-state"
    cleanup: str = ""
    cleanup_abs: str = ""
    note: str = ""


@dataclass(frozen=True)
class MountItem:
    name: str
    what: str
    where: str
    type: str = "auto"
    options: tuple[str, ...] = ("defaults", "noatime")
    automount: bool = True
    timeout_idle_sec: str = "600"
    directory_mode: str = "755"
    wanted_by: str = "multi-user.target"

    @property
    def mount_unit(self) -> str:
        return systemd_escape_path(self.where) + ".mount"

    @property
    def automount_unit(self) -> str:
        return systemd_escape_path(self.where) + ".automount"

    @property
    def enabled_unit(self) -> str:
        return self.automount_unit if self.automount else self.mount_unit


@dataclass
class ResolvedState:
    profile: str
    config: dict[str, Any]
    features: list[str] = field(default_factory=list)
    pacman: list[str] = field(default_factory=list)
    aur: list[str] = field(default_factory=list)
    dirs: list[DirItem] = field(default_factory=list)
    files: list[FileItem] = field(default_factory=list)
    links: list[LinkItem] = field(default_factory=list)
    systemd: list[SystemdItem] = field(default_factory=list)
    hooks: list[HookItem] = field(default_factory=list)
    mounts: list[MountItem] = field(default_factory=list)


def systemd_escape_path(path: str) -> str:
    clean = path.strip("/")
    if not clean:
        return "-"
    out: list[str] = []
    for ch in clean:
        if ch == "/":
            out.append("-")
        elif ch.isalnum() or ch in "_.":
            out.append(ch)
        else:
            out.append("\\x" + format(ord(ch), "02x"))
    return "".join(out)
