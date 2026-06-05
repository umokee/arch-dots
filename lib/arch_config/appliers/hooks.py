from __future__ import annotations

from pathlib import Path

from arch_config.model import HookItem
from arch_config.paths import ROOT
from arch_config.state.hooks import (
    run_disabled_hook_cleanups as _run_disabled_hook_cleanups,
)
from arch_config.system.shell import run
from arch_config.ui import print_info, print_section


def run_hook(hook: HookItem, *, dry_run: bool) -> None:
    script = Path(hook.script_abs)
    print_info(f"hook {hook.run} {hook.feature}:{hook.name}")
    run(["bash", str(script)], dry_run=dry_run, cwd=ROOT)


def run_hooks(
    hooks: list[HookItem],
    phase: str,
    *,
    dry_run: bool,
) -> None:
    selected = [hook for hook in hooks if hook.run == phase]

    if not selected:
        return

    print_section(f"{phase} hooks")

    for hook in selected:
        run_hook(hook, dry_run=dry_run)


def run_disabled_hook_cleanups(
    entries: list[dict],
    *,
    dry_run: bool,
) -> None:
    _run_disabled_hook_cleanups(entries, dry_run=dry_run)
