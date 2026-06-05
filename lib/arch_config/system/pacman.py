from __future__ import annotations

import fnmatch
import subprocess

from arch_config.core.models import DesiredState
from arch_config.paths import ROOT
from arch_config.system.shell import run_root


def installed_packages() -> set[str]:
    try:
        out = subprocess.check_output(
            ["pacman", "-Qq"], text=True, stderr=subprocess.DEVNULL
        )
        return set(out.splitlines())
    except Exception:
        return set()


def foreign_packages() -> set[str]:
    try:
        out = subprocess.check_output(
            ["pacman", "-Qmq"], text=True, stderr=subprocess.DEVNULL
        )
        return set(out.splitlines())
    except Exception:
        return set()


def explicit_native_packages() -> set[str]:
    try:
        out = subprocess.check_output(
            ["pacman", "-Qqen"], text=True, stderr=subprocess.DEVNULL
        )
        return set(out.splitlines())
    except Exception:
        return set()


def orphan_packages() -> set[str]:
    try:
        out = subprocess.check_output(
            ["pacman", "-Qqdt"], text=True, stderr=subprocess.DEVNULL
        )
        return set(out.splitlines())
    except Exception:
        return set()


def missing_native(state: DesiredState, installed: set[str] | None = None) -> list[str]:
    installed = installed if installed is not None else installed_packages()
    return [pkg for pkg in state.pacman if pkg not in installed]


def missing_foreign(state: DesiredState, installed: set[str] | None = None) -> list[str]:
    installed = installed if installed is not None else installed_packages()
    return [pkg for pkg in state.aur if pkg not in installed]


def _protected_by_pattern(pkg: str, patterns: list[str]) -> bool:
    return any(fnmatch.fnmatch(pkg, pat) for pat in patterns)


def prune_plan_for_state(
    state: DesiredState,
    *,
    include_aur: bool = True,
    include_orphans: bool = False,
) -> dict[str, list[str]]:
    ignore = (
        state.config.get("ignore", {})
        if isinstance(state.config.get("ignore", {}), dict)
        else {}
    )
    prune_cfg = (
        state.config.get("prune", {})
        if isinstance(state.config.get("prune", {}), dict)
        else {}
    )

    ignored_native = set(str(x) for x in ignore.get("pacman", []))
    ignored_foreign = set(str(x) for x in ignore.get("foreign", []))
    protected = set(str(x) for x in prune_cfg.get("protected", []))
    patterns = [str(x) for x in prune_cfg.get("protect_patterns", [])]

    wanted_packages = (
        set(state.pacman)
        | set(state.aur)
        | ignored_native
        | ignored_foreign
        | protected
    )

    native_remove = sorted(
        pkg
        for pkg in explicit_native_packages()
        if pkg not in wanted_packages and not _protected_by_pattern(pkg, patterns)
    )

    foreign_remove = sorted(
        pkg
        for pkg in foreign_packages()
        if include_aur
        and pkg not in wanted_packages
        and not _protected_by_pattern(pkg, patterns)
    )

    orphans_remove = sorted(orphan_packages()) if include_orphans else []

    return {"pacman": native_remove, "aur": foreign_remove, "orphans": orphans_remove}


def prune_remove_list(plan: dict[str, list[str]] | None) -> list[str]:
    if not plan:
        return []
    return [*plan.get("pacman", []), *plan.get("aur", []), *plan.get("orphans", [])]


def remove_packages(
    packages: list[str],
    *,
    dry_run: bool,
) -> None:
    if not packages:
        return

    run_root(["pacman", "-Rns", "--", *packages], dry_run=dry_run, cwd=ROOT)


def install_native_packages(
    packages: list[str],
    *,
    dry_run: bool,
) -> None:
    if not packages:
        return

    run_root(["pacman", "-S", "--needed", *packages], dry_run=dry_run, cwd=ROOT)
