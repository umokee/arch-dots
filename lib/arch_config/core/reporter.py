from __future__ import annotations

from arch_config.core.models import SwitchPlan
from arch_config.system.pacman import prune_remove_list
from arch_config.ui import (
    is_verbose,
    operation_group_counts,
    print_header,
    print_key_values,
    print_list,
    print_muted,
    print_success,
    print_table,
    print_warning,
)


def print_switch_plan(plan: SwitchPlan) -> None:
    state = plan.state
    subtitle = "dry-run" if plan.options.dry_run else "apply"
    if plan.options.strict:
        subtitle += " · strict prune"
    if plan.options.with_aur:
        subtitle += " · aur enabled"
    elif state.aur:
        subtitle += " · aur skipped"

    print_header("archctl plan", f"profile: {plan.profile} · mode: {subtitle}")

    print_key_values(
        "Summary",
        [
            ("features", len(state.features)),
            ("operations", len(plan.operations)),
            (
                "pacman",
                f"{len(state.pacman)} wanted, {len(plan.missing_pacman)} missing",
            ),
            ("aur", f"{len(state.aur)} wanted, {len(plan.missing_aur)} missing"),
            ("files", len(state.files)),
            ("dirs", len(state.dirs)),
            ("links", len(state.links)),
            ("systemd", len(state.systemd)),
            ("mounts", len(state.mounts)),
            ("hooks", len(state.hooks)),
        ],
    )

    print_table(
        "Operation groups",
        ["Group", "Count"],
        [
            (group, count)
            for group, count in operation_group_counts(
                op.kind for op in plan.operations
            )
        ],
    )

    if plan.missing_pacman:
        print_list("Missing pacman packages", plan.missing_pacman, marker="+")

    if plan.missing_aur:
        print_list("Missing AUR packages", plan.missing_aur, marker="+")
    elif state.aur and not plan.options.with_aur:
        print_warning(
            "AUR packages are declared, but this plan was built without --aur"
        )

    stale_count = (
        len(plan.stale_file_entries)
        + len(plan.stale_systemd_entries)
        + len(plan.disabled_hook_entries)
    )
    strict_remove = prune_remove_list(plan.strict_prune_plan)
    if stale_count or strict_remove:
        print_table(
            "Cleanup preview",
            ["Type", "Count"],
            [
                ("stale managed files", len(plan.stale_file_entries)),
                ("stale systemd units", len(plan.stale_systemd_entries)),
                ("disabled hooks", len(plan.disabled_hook_entries)),
                ("strict package prune", len(strict_remove)),
            ],
        )

    if state.mounts:
        print_table(
            "Mounts",
            ["What", "Where", "Unit"],
            [(mount.what, mount.where, mount.enabled_unit) for mount in state.mounts],
            max_rows=None if is_verbose() else 12,
        )

    if is_verbose():
        print_files(plan)
        print_operation_list(plan)
    else:
        print_muted("set ARCHCTL_VERBOSE=1 to show files and full operation list")


def print_files(plan: SwitchPlan) -> None:
    state = plan.state
    print_table(
        "Files",
        ["Mode", "Feature", "Source", "Target"],
        [(item.mode, item.feature, item.source, item.target) for item in state.files],
    )

    if state.links:
        print_table(
            "Links",
            ["Source", "Target"],
            [(item.source, item.target) for item in state.links],
        )


def print_state_diff_from_plan(plan: SwitchPlan) -> None:
    printed = False

    if plan.stale_file_entries:
        print_stale_file_table(plan.stale_file_entries)
        printed = True

    if plan.disabled_hook_entries:
        print_disabled_hook_table(plan.disabled_hook_entries)
        printed = True

    if plan.stale_systemd_entries:
        print_stale_systemd_table(plan.stale_systemd_entries)
        printed = True

    if not printed:
        print_success("no stale managed files, disabled hooks or stale systemd units")


def print_stale_file_table(entries: list[dict]) -> None:
    print_table(
        "Stale managed files",
        ["Target", "Old feature", "Kind", "Unit cleanup"],
        [
            (
                str(entry.get("target") or "?"),
                str(entry.get("feature") or "?"),
                str(entry.get("kind") or entry.get("type") or "?"),
                _unit_cleanup(entry),
            )
            for entry in entries
        ],
    )


def print_disabled_hook_table(entries: list[dict]) -> None:
    rows = []
    for entry in entries:
        kind = str(entry.get("kind") or "external-state")
        cleanup = str(entry.get("cleanup") or "")
        if cleanup:
            action = f"run cleanup: {cleanup}"
        elif kind == "generator":
            action = "no cleanup needed"
        else:
            action = "manual cleanup may be needed"
        rows.append(
            (f"{entry.get('feature') or '?'}:{entry.get('name') or '?'}", kind, action)
        )

    print_table("Disabled hooks", ["Hook", "Kind", "Action"], rows)


def print_stale_systemd_table(entries: list[dict]) -> None:
    rows = []
    for entry in entries:
        enable = bool(entry.get("enable"))
        start = bool(entry.get("start"))
        if enable and start:
            action = "disable --now"
        elif enable:
            action = "disable"
        elif start:
            action = "stop"
        else:
            action = "no-op"
        rows.append(
            (
                str(entry.get("scope") or "?"),
                str(entry.get("unit") or "?"),
                str(entry.get("feature") or "?"),
                action,
            )
        )

    print_table("Stale systemd units", ["Scope", "Unit", "Old feature", "Action"], rows)


def print_operation_list(plan: SwitchPlan) -> None:
    if not plan.operations:
        return

    rows = [
        (index, operation.kind, operation.scope, operation.title)
        for index, operation in enumerate(plan.operations, start=1)
    ]
    print_table("Operations", ["#", "Kind", "Scope", "Title"], rows)


def print_prune_table(profile: str, plan: dict[str, list[str]]) -> None:
    print_header("archctl prune", f"profile: {profile}")
    print_table(
        "Summary",
        ["Group", "Remove"],
        [
            ("native explicit", len(plan.get("pacman") or [])),
            ("foreign / AUR", len(plan.get("aur") or [])),
            ("orphans", len(plan.get("orphans") or [])),
        ],
    )

    for title, key in [
        ("Native packages", "pacman"),
        ("Foreign / AUR packages", "aur"),
        ("Orphan packages", "orphans"),
    ]:
        values = list(plan.get(key) or [])
        if values:
            print_list(title, values, marker="-")


def print_validation_result(
    profile: str, errors: list[str], warnings: list[str]
) -> None:
    print_header("archctl validate", f"profile: {profile}")

    for warning in warnings:
        print_warning(warning)

    from arch_config.ui import print_error

    for error in errors:
        print_error(error)

    if not errors:
        print_success("config schema looks good")


def _unit_cleanup(entry: dict) -> str:
    unit_scope = str(entry.get("unit_scope") or "")
    unit = str(entry.get("unit") or "")
    if unit_scope and unit:
        return f"{unit_scope}:{unit}"
    return ""
