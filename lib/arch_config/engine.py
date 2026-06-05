from __future__ import annotations

import json
import shutil
from typing import Any

from arch_config.core.executor import execute_switch_plan
from arch_config.core.models import SwitchOptions
from arch_config.core.planner import build_switch_plan
from arch_config.core.reporter import (
    print_prune_table,
    print_state_diff_from_plan,
    print_switch_plan,
    print_validation_result,
)
from arch_config.core.resolver import resolve
from arch_config.core.validator import validate
from arch_config.model import ResolvedState
from arch_config.paths import GENERATED_DIR
from arch_config.render.files import render_file
from arch_config.render.systemd_units import render_automount_unit, render_mount_unit
from arch_config.system.pacman import (
    prune_plan_for_state,
    prune_remove_list,
    remove_packages,
)
from arch_config.ui import print_success, print_warning


def manifest(state: ResolvedState) -> dict[str, Any]:
    return {
        "profile": state.profile,
        "features": state.features,
        "pacman": state.pacman,
        "aur": state.aur,
        "dirs": [
            {
                "target": item.target,
                "target_abs": str(item.target_abs),
                "permissions": item.permissions,
            }
            for item in state.dirs
        ],
        "files": [
            {
                "feature": item.feature,
                "source": item.source,
                "target": item.target,
                "mode": item.mode,
                "type": item.type,
            }
            for item in state.files
        ],
        "links": [
            {"source": item.source, "target": item.target} for item in state.links
        ],
        "systemd": [item.__dict__ for item in state.systemd],
        "hooks": [
            {
                "feature": item.feature,
                "name": item.name,
                "script": item.script,
                "script_abs": item.script_abs,
                "run": item.run,
                "kind": item.kind,
                "cleanup": item.cleanup,
                "cleanup_abs": item.cleanup_abs,
                "note": item.note,
            }
            for item in state.hooks
        ],
        "mounts": [
            {
                "name": item.name,
                "what": item.what,
                "where": item.where,
                "unit": item.enabled_unit,
            }
            for item in state.mounts
        ],
    }


def write_generated(profile: str) -> ResolvedState:
    state = resolve(profile)

    if GENERATED_DIR.exists():
        shutil.rmtree(GENERATED_DIR)

    (GENERATED_DIR / "packages").mkdir(parents=True)
    (GENERATED_DIR / "files").mkdir(parents=True)
    (GENERATED_DIR / "systemd").mkdir(parents=True)
    (GENERATED_DIR / "hooks").mkdir(parents=True)

    (GENERATED_DIR / "packages/pacman.txt").write_text(
        "\n".join(state.pacman) + "\n",
        encoding="utf-8",
    )
    (GENERATED_DIR / "packages/aur.txt").write_text(
        "\n".join(state.aur) + "\n",
        encoding="utf-8",
    )

    for item in state.files:
        if item.mode in {"copy", "template"}:
            safe = item.target.strip("~/").replace("/", "__") or item.name
            (GENERATED_DIR / "files" / safe).write_text(
                render_file(item, state.config),
                encoding="utf-8",
            )

    for mount in state.mounts:
        (GENERATED_DIR / "files" / mount.mount_unit).write_text(
            render_mount_unit(mount),
            encoding="utf-8",
        )
        if mount.automount:
            (GENERATED_DIR / "files" / mount.automount_unit).write_text(
                render_automount_unit(mount),
                encoding="utf-8",
            )

    (GENERATED_DIR / "links.txt").write_text(
        "\n".join(f"{item.target} -> {item.source}" for item in state.links)
        + ("\n" if state.links else ""),
        encoding="utf-8",
    )
    (GENERATED_DIR / "systemd/system.txt").write_text(
        "\n".join(item.unit for item in state.systemd if item.scope == "system") + "\n",
        encoding="utf-8",
    )
    (GENERATED_DIR / "systemd/user.txt").write_text(
        "\n".join(item.unit for item in state.systemd if item.scope == "user") + "\n",
        encoding="utf-8",
    )
    (GENERATED_DIR / "hooks/post.txt").write_text(
        "\n".join(item.script for item in state.hooks if item.run == "post") + "\n",
        encoding="utf-8",
    )
    (GENERATED_DIR / "manifest.json").write_text(
        json.dumps(manifest(state), indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8",
    )

    return state


def print_plan(profile: str) -> ResolvedState:
    plan = build_switch_plan(
        profile,
        SwitchOptions(dry_run=True, include_file_hashes=False),
    )
    print_switch_plan(plan)
    return plan.state


def print_state_diff(profile: str) -> None:
    plan = build_switch_plan(
        profile,
        SwitchOptions(dry_run=True, include_file_hashes=False),
    )
    print_state_diff_from_plan(plan)


def prune_plan(
    profile: str,
    *,
    include_aur: bool = True,
    include_orphans: bool = False,
) -> dict[str, list[str]]:
    state = resolve(profile)
    return prune_plan_for_state(
        state,
        include_aur=include_aur,
        include_orphans=include_orphans,
    )


def show_prune_plan(profile: str, plan: dict[str, list[str]]) -> None:
    print_prune_table(profile, plan)


def print_prune_plan(
    profile: str,
    *,
    include_aur: bool = True,
    include_orphans: bool = False,
) -> dict[str, list[str]]:
    plan = prune_plan(
        profile,
        include_aur=include_aur,
        include_orphans=include_orphans,
    )
    show_prune_plan(profile, plan)
    return plan


def apply_prune_plan(
    profile: str,
    *,
    include_aur: bool = True,
    include_orphans: bool = False,
    dry_run: bool = False,
    yes: bool = False,
    plan: dict[str, list[str]] | None = None,
    show: bool = True,
) -> int:
    if plan is None:
        plan = prune_plan(
            profile,
            include_aur=include_aur,
            include_orphans=include_orphans,
        )

    if show:
        show_prune_plan(profile, plan)

    remove = prune_remove_list(plan)

    if not remove:
        if show:
            print_success("nothing to prune")
        return 0

    if not yes and not dry_run:
        answer = input("Remove these packages? [y/N] ").strip().lower()
        if answer not in {"y", "yes"}:
            print_warning("cancelled")
            return 1

    remove_packages(remove, dry_run=dry_run)
    return 0


def switch(
    profile: str,
    *,
    with_aur: bool = False,
    helper: str = "yay",
    dry_run: bool = False,
    yes: bool = False,
    strict: bool = False,
    prune_aur: bool = True,
    include_orphans: bool = False,
    prune_files: bool = True,
) -> int:
    code, errors, warnings = validate(profile)

    if warnings or errors:
        print_validation_result(profile, errors, warnings)

    if errors:
        return 1

    options = SwitchOptions(
        with_aur=with_aur,
        helper=helper,
        dry_run=dry_run,
        strict=strict,
        prune_aur=prune_aur,
        include_orphans=include_orphans,
        prune_files=prune_files,
        include_file_hashes=not dry_run,
    )
    plan = build_switch_plan(profile, options)

    print_switch_plan(plan)

    if (
        plan.disabled_hook_entries
        or plan.stale_systemd_entries
        or (plan.stale_file_entries and prune_files)
    ):
        print_state_diff_from_plan(plan)

    if strict:
        print_warning(
            "strict package cleanup is enabled; "
            + "listed packages WILL be removed before commit"
        )
        show_prune_plan(
            profile, plan.strict_prune_plan or {"pacman": [], "aur": [], "orphans": []}
        )

        if not prune_remove_list(plan.strict_prune_plan):
            print_success("nothing to prune")

    if not yes and not dry_run:
        if strict and prune_remove_list(plan.strict_prune_plan):
            prompt = "Apply this plan and remove the packages listed above? [y/N] "
        else:
            prompt = "Apply this plan? [y/N] "

        answer = input(prompt).strip().lower()
        if answer not in {"y", "yes"}:
            print_warning("cancelled")
            return 1

    return execute_switch_plan(plan)
