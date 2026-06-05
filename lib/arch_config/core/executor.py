from __future__ import annotations

from arch_config.appliers.files import apply_dir, apply_file, apply_link
from arch_config.appliers.hooks import run_disabled_hook_cleanups, run_hook
from arch_config.appliers.mounts import apply_mount_unit
from arch_config.appliers.packages import (
    apply_aur_package,
    apply_pacman_packages,
    apply_strict_prune,
)
from arch_config.appliers.systemd import (
    apply_systemd_unit_action,
    systemd_daemon_reload,
)
from arch_config.core.models import Operation, SwitchPlan
from arch_config.state.files import prune_stale_managed_files, save_files_state
from arch_config.state.hooks import save_hooks_state
from arch_config.state.store import commit_pending_state, reset_pending_state
from arch_config.state.systemd import run_stale_systemd_cleanup, save_systemd_state
from arch_config.ui import (
    operation_group,
    print_header,
    print_info,
    print_operation_step,
    print_section,
    print_success,
    print_warning,
)

_GROUP_TITLES = {
    "packages": "Packages",
    "files": "Files and generated units",
    "cleanup": "Cleanup",
    "systemd": "Systemd",
    "hooks": "Hooks",
    "state": "State",
}


def execute_switch_plan(plan: SwitchPlan) -> int:
    mode = "dry-run" if plan.options.dry_run else "apply"
    if plan.options.strict:
        mode += " · strict"
    if plan.options.with_aur:
        mode += " · aur"

    print_header("archctl switch", f"profile: {plan.profile} · mode: {mode}")

    previous_group: str | None = None
    total = len(plan.operations)

    for index, operation in enumerate(plan.operations, start=1):
        group = operation_group(operation.kind)
        if group != previous_group:
            print_section(_GROUP_TITLES.get(group, group.title()))
            previous_group = group

        print_operation_step(
            index, total, operation.kind, operation.scope, operation.title
        )
        _execute_operation(plan, operation)

    if plan.options.dry_run:
        print_success("dry-run completed")
    else:
        print_success("switch completed")

    return 0


def _execute_operation(plan: SwitchPlan, operation: Operation) -> None:
    dry_run = plan.options.dry_run
    state = plan.state
    payload = operation.payload

    match operation.kind:
        case "state.reset":
            reset_pending_state(plan.profile, dry_run=dry_run)

        case "package.pacman.install":
            apply_pacman_packages(list(payload.get("packages", [])), dry_run=dry_run)

        case "package.aur.install":
            apply_aur_package(
                str(payload["package"]), helper=plan.options.helper, dry_run=dry_run
            )

        case "package.aur.skip":
            print_warning("AUR skipped. Use --aur to install AUR packages.")

        case "hook.pre.begin" | "hook.post.begin":
            phase = "pre" if operation.kind.startswith("hook.pre") else "post"
            print_info(f"{phase} hooks")

        case "hook.pre" | "hook.post":
            run_hook(state.hooks[int(payload["hook_index"])], dry_run=dry_run)

        case "file.dir.ensure":
            apply_dir(
                state.dirs[int(payload["dir_index"])], state.config, dry_run=dry_run
            )

        case "file.write" | "file.symlink":
            apply_file(
                state.files[int(payload["file_index"])], state.config, dry_run=dry_run
            )

        case "file.link":
            apply_link(state.links[int(payload["link_index"])], dry_run=dry_run)

        case "mount.unit.write" | "mount.automount.write":
            apply_mount_unit(
                state.mounts[int(payload["mount_index"])],
                state.config,
                automount=bool(payload.get("automount", False)),
                dry_run=dry_run,
            )

        case "cleanup.systemd.stale":
            run_stale_systemd_cleanup(plan.stale_systemd_entries, dry_run=dry_run)

        case "cleanup.file.stale":
            prune_stale_managed_files(
                plan.profile,
                plan.current_files_state,
                dry_run=dry_run,
            )

        case "cleanup.hook.disabled":
            run_disabled_hook_cleanups(plan.disabled_hook_entries, dry_run=dry_run)

        case "systemd.daemon_reload":
            systemd_daemon_reload(operation.scope, dry_run=dry_run)

        case "systemd.enable":
            apply_systemd_unit_action(
                state.systemd[int(payload["unit_index"])],
                "enable",
                dry_run=dry_run,
            )

        case "systemd.start":
            apply_systemd_unit_action(
                state.systemd[int(payload["unit_index"])],
                "start",
                dry_run=dry_run,
            )

        case "state.save.files":
            save_files_state(
                plan.profile,
                plan.current_files_state,
                dry_run=dry_run,
                pending=True,
            )

        case "state.save.systemd":
            save_systemd_state(
                plan.profile,
                plan.current_systemd_state,
                dry_run=dry_run,
                pending=True,
            )

        case "state.save.hooks":
            save_hooks_state(
                plan.profile,
                plan.current_hooks_state,
                dry_run=dry_run,
                pending=True,
            )

        case "package.prune.strict":
            apply_strict_prune(plan)

        case "state.commit":
            commit_pending_state(
                plan.profile,
                ["files.json", "systemd.json", "hooks.json"],
                dry_run=dry_run,
            )

        case _:
            raise RuntimeError(f"unsupported operation kind: {operation.kind}")
