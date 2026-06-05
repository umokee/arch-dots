from __future__ import annotations

import json
from pathlib import Path
from typing import Any

from arch_config.model import HookItem, ResolvedState
from arch_config.paths import ROOT
from arch_config.system.shell import run
from arch_config.state.store import save_json_state, state_json_path

STATE_DIR = ROOT / "state"
STATE_VERSION = 1

KNOWN_HOOK_KINDS = {
    "generator",
    "managed-external-files",
    "external-state",
    "sync",
}


def hooks_state_path(profile: str, *, pending: bool = False) -> Path:
    return state_json_path(profile, "hooks.json", pending=pending)


def _hook_key(entry: dict[str, Any]) -> str:
    feature = str(entry.get("feature") or "")
    name = str(entry.get("name") or "")
    return f"{feature}:{name}"


def _hook_to_entry(hook: HookItem) -> dict[str, Any]:
    return {
        "feature": hook.feature,
        "name": hook.name,
        "script": hook.script,
        "script_abs": hook.script_abs,
        "run": hook.run,
        "kind": hook.kind,
        "cleanup": hook.cleanup,
        "cleanup_abs": hook.cleanup_abs,
        "note": hook.note,
    }


def build_hooks_state(state: ResolvedState) -> dict[str, Any]:
    hooks: dict[str, Any] = {}

    for hook in state.hooks:
        entry = _hook_to_entry(hook)
        hooks[_hook_key(entry)] = entry

    return {
        "version": STATE_VERSION,
        "profile": state.profile,
        "hooks": hooks,
    }


def load_hooks_state(profile: str) -> dict[str, Any]:
    path = hooks_state_path(profile)

    if not path.exists():
        return {
            "version": STATE_VERSION,
            "profile": profile,
            "hooks": {},
        }

    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except Exception:
        print(f"warning: broken hooks state, ignoring: {path}")
        return {
            "version": STATE_VERSION,
            "profile": profile,
            "hooks": {},
        }


def save_hooks_state(
    profile: str,
    state: dict[str, Any],
    *,
    dry_run: bool,
    pending: bool = False,
) -> None:
    save_json_state(
        profile,
        "hooks.json",
        state,
        dry_run=dry_run,
        pending=pending,
    )


def disabled_hooks(
    profile: str,
    current_state: dict[str, Any],
) -> list[dict[str, Any]]:
    old_state = load_hooks_state(profile)

    old_hooks: dict[str, Any] = dict(old_state.get("hooks") or {})
    current_hooks: dict[str, Any] = dict(current_state.get("hooks") or {})

    if not old_hooks:
        return []

    result: list[dict[str, Any]] = []

    for key in sorted(set(old_hooks) - set(current_hooks)):
        raw = old_hooks[key]
        if isinstance(raw, dict):
            result.append(raw)

    return result


def print_disabled_hooks(entries: list[dict[str, Any]]) -> None:
    if not entries:
        return

    print("Disabled hooks cleanup preview:")

    for entry in entries:
        feature = str(entry.get("feature") or "?")
        name = str(entry.get("name") or "?")
        kind = str(entry.get("kind") or "external-state")
        cleanup = str(entry.get("cleanup") or "")
        note = str(entry.get("note") or "")

        print(f"  - {feature}:{name}")
        print(f"    kind: {kind}")

        if cleanup:
            print(f"    cleanup: {cleanup}")
        elif kind == "generator":
            print("    action: no cleanup needed")
        else:
            print("    action: manual cleanup may be needed")

        if note:
            print(f"    note: {note}")


def run_disabled_hook_cleanups(
    entries: list[dict[str, Any]],
    *,
    dry_run: bool,
) -> None:
    if not entries:
        return

    print("\nDisabled hooks:")

    for entry in entries:
        feature = str(entry.get("feature") or "?")
        name = str(entry.get("name") or "?")
        kind = str(entry.get("kind") or "external-state")
        cleanup = str(entry.get("cleanup") or "")
        cleanup_abs = str(entry.get("cleanup_abs") or "")
        note = str(entry.get("note") or "")

        title = f"{feature}:{name}"

        if cleanup and cleanup_abs:
            script = Path(cleanup_abs)

            if not script.exists() and not dry_run:
                print(f"  warning: cleanup script missing for {title}: {script}")
                continue

            print(f"  cleanup {title}: {script}")
            run(["bash", str(script)], dry_run=dry_run, cwd=ROOT)
            continue

        if kind == "generator":
            print(f"  skip generator {title}: cleanup is not needed")
            continue

        print(f"  warning: disabled hook has no cleanup: {title}")
        print(f"    kind: {kind}")

        if note:
            print(f"    note: {note}")
