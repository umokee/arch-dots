from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

from arch_config.model import ResolvedState

DesiredState = ResolvedState


@dataclass(frozen=True)
class Context:
    profile: str
    root: Path
    dry_run: bool = False


@dataclass(frozen=True)
class Operation:
    kind: str
    title: str
    scope: str = "user"
    payload: dict[str, Any] = field(default_factory=dict)


@dataclass(frozen=True)
class SwitchOptions:
    with_aur: bool = False
    helper: str = "yay"
    dry_run: bool = False
    strict: bool = False
    prune_aur: bool = True
    include_orphans: bool = False
    prune_files: bool = True
    include_file_hashes: bool = True


@dataclass
class SwitchPlan:
    profile: str
    state: DesiredState
    options: SwitchOptions
    operations: list[Operation] = field(default_factory=list)
    current_files_state: dict[str, Any] = field(default_factory=dict)
    current_systemd_state: dict[str, Any] = field(default_factory=dict)
    current_hooks_state: dict[str, Any] = field(default_factory=dict)
    stale_file_entries: list[dict[str, Any]] = field(default_factory=list)
    stale_systemd_entries: list[dict[str, Any]] = field(default_factory=list)
    disabled_hook_entries: list[dict[str, Any]] = field(default_factory=list)
    missing_pacman: list[str] = field(default_factory=list)
    missing_aur: list[str] = field(default_factory=list)
    strict_prune_plan: dict[str, list[str]] | None = None
