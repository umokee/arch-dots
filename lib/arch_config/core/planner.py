from __future__ import annotations

from pathlib import Path

from arch_config.core.models import Operation, SwitchOptions, SwitchPlan
from arch_config.core.resolver import resolve
from arch_config.state.files import build_files_state, stale_managed_files
from arch_config.state.hooks import build_hooks_state, disabled_hooks
from arch_config.state.systemd import build_systemd_state, stale_systemd_units
from arch_config.system.pacman import (
    installed_packages,
    missing_foreign,
    missing_native,
    prune_plan_for_state,
    prune_remove_list,
)


def build_switch_plan(profile: str, options: SwitchOptions | None = None) -> SwitchPlan:
    options = options or SwitchOptions(include_file_hashes=False)
    state = resolve(profile)
    installed = installed_packages()
    missing_pacman = missing_native(state, installed)
    missing_aur = missing_foreign(state, installed)

    current_files_state = build_files_state(
        state,
        include_hashes=options.include_file_hashes and not options.dry_run,
    )
    current_hooks_state = build_hooks_state(state)
    current_systemd_state = build_systemd_state(state)

    strict_prune_plan = None
    if options.strict:
        strict_prune_plan = prune_plan_for_state(
            state,
            include_aur=(options.with_aur and options.prune_aur),
            include_orphans=options.include_orphans,
        )

    plan = SwitchPlan(
        profile=profile,
        state=state,
        options=options,
        current_files_state=current_files_state,
        current_systemd_state=current_systemd_state,
        current_hooks_state=current_hooks_state,
        stale_file_entries=stale_managed_files(profile, current_files_state),
        stale_systemd_entries=stale_systemd_units(profile, current_systemd_state),
        disabled_hook_entries=disabled_hooks(profile, current_hooks_state),
        missing_pacman=missing_pacman,
        missing_aur=missing_aur,
        strict_prune_plan=strict_prune_plan,
    )

    _build_operations(plan)
    return plan


def _op(kind: str, title: str, scope: str = "user", **payload: object) -> Operation:
    return Operation(kind=kind, title=title, scope=scope, payload=dict(payload))


def _build_operations(plan: SwitchPlan) -> None:
    plan.operations.append(_op("state.reset", "reset pending state", "user"))

    _add_package_operations(plan)
    _add_hook_operations(plan, "pre")
    _add_file_operations(plan)
    _add_mount_operations(plan)
    _add_cleanup_operations(plan)
    _add_systemd_operations(plan)
    _add_hook_operations(plan, "post")
    _add_state_operations(plan)


def _add_package_operations(plan: SwitchPlan) -> None:
    if plan.missing_pacman:
        plan.operations.append(
            _op(
                "package.pacman.install",
                f"{len(plan.missing_pacman)} pacman package(s)",
                "system",
                packages=list(plan.missing_pacman),
            )
        )

    if plan.options.with_aur:
        for package in plan.missing_aur:
            plan.operations.append(
                _op("package.aur.install", package, "user", package=package)
            )
    elif plan.state.aur:
        plan.operations.append(
            _op(
                "package.aur.skip",
                f"AUR skipped: {len(plan.state.aur)} package(s)",
                "user",
            )
        )


def _add_hook_operations(plan: SwitchPlan, phase: str) -> None:
    phase_hooks = [hook for hook in plan.state.hooks if hook.run == phase]
    if phase_hooks:
        plan.operations.append(_op(f"hook.{phase}.begin", f"{phase} hooks", "user"))

    for index, hook in enumerate(plan.state.hooks):
        if hook.run != phase:
            continue

        plan.operations.append(
            _op(
                f"hook.{phase}",
                f"{hook.feature}:{hook.name}",
                "user",
                hook_index=index,
                script=hook.script_abs,
                hook_kind=hook.kind,
            )
        )


def _add_file_operations(plan: SwitchPlan) -> None:
    home = _state_home(plan)

    for index, directory in enumerate(plan.state.dirs):
        scope = _scope_for_target(directory.target_abs, home)
        plan.operations.append(
            _op(
                "file.dir.ensure",
                str(directory.target_abs),
                scope,
                dir_index=index,
                permissions=directory.permissions,
            )
        )

    for index, item in enumerate(plan.state.files):
        scope = _scope_for_target(item.target_abs, home)
        kind = "file.symlink" if item.mode == "link" else "file.write"

        plan.operations.append(
            _op(
                kind,
                str(item.target_abs),
                scope,
                file_index=index,
                feature=item.feature,
                source=str(item.source_abs),
                mode=item.mode,
            )
        )

    for index, item in enumerate(plan.state.links):
        plan.operations.append(
            _op(
                "file.link",
                str(item.target_abs),
                "user",
                link_index=index,
                source=str(item.source_abs),
            )
        )


def _add_mount_operations(plan: SwitchPlan) -> None:
    for index, mount in enumerate(plan.state.mounts):
        plan.operations.append(
            _op(
                "mount.unit.write",
                f"/etc/systemd/system/{mount.mount_unit}",
                "system",
                mount_index=index,
                automount=False,
                mount=mount.where,
            )
        )

        if mount.automount:
            plan.operations.append(
                _op(
                    "mount.automount.write",
                    f"/etc/systemd/system/{mount.automount_unit}",
                    "system",
                    mount_index=index,
                    automount=True,
                    mount=mount.where,
                )
            )


def _add_cleanup_operations(plan: SwitchPlan) -> None:
    if plan.stale_systemd_entries:
        plan.operations.append(
            _op(
                "cleanup.systemd.stale",
                f"{len(plan.stale_systemd_entries)} stale systemd unit(s)",
                "system",
            )
        )

    if plan.options.prune_files and plan.stale_file_entries:
        plan.operations.append(
            _op(
                "cleanup.file.stale",
                f"{len(plan.stale_file_entries)} stale managed file(s)",
                "system",
            )
        )

    if plan.disabled_hook_entries:
        plan.operations.append(
            _op(
                "cleanup.hook.disabled",
                f"{len(plan.disabled_hook_entries)} disabled hook cleanup(s)",
                "user",
            )
        )


def _add_systemd_operations(plan: SwitchPlan) -> None:
    has_system_units = any(
        item.scope == "system" for item in plan.state.systemd
    ) or bool(plan.state.mounts)
    has_user_units = any(item.scope == "user" for item in plan.state.systemd)

    if has_system_units:
        plan.operations.append(
            _op("systemd.daemon_reload", "system daemon-reload", "system")
        )

    if has_user_units:
        plan.operations.append(
            _op("systemd.daemon_reload", "user daemon-reload", "user")
        )

    for index, unit in enumerate(plan.state.systemd):
        if unit.enable:
            plan.operations.append(
                _op(
                    "systemd.enable",
                    f"{unit.scope}:{unit.unit}",
                    unit.scope,
                    unit_index=index,
                )
            )

        if unit.start:
            plan.operations.append(
                _op(
                    "systemd.start",
                    f"{unit.scope}:{unit.unit}",
                    unit.scope,
                    unit_index=index,
                )
            )


def _add_state_operations(plan: SwitchPlan) -> None:
    plan.operations.append(_op("state.save.files", "files.json", "user"))
    plan.operations.append(_op("state.save.systemd", "systemd.json", "user"))
    plan.operations.append(_op("state.save.hooks", "hooks.json", "user"))

    if plan.options.strict and prune_remove_list(plan.strict_prune_plan):
        plan.operations.append(
            _op(
                "package.prune.strict",
                f"remove {len(prune_remove_list(plan.strict_prune_plan))} package(s)",
                "system",
            )
        )

    plan.operations.append(_op("state.commit", "commit pending state", "user"))


def _state_home(plan: SwitchPlan) -> Path:
    raw_home = plan.state.config.get("_home") or plan.state.config.get("home") or "~"
    return Path(str(raw_home)).expanduser().resolve(strict=False)


def _scope_for_target(target: Path, home: Path) -> str:
    if not target.is_absolute():
        return "user"

    return "user" if _is_inside(target, home) else "system"


def _is_inside(path: Path, base: Path) -> bool:
    try:
        path.resolve(strict=False).relative_to(base.resolve(strict=False))
        return True
    except ValueError:
        return False
