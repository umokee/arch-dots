from __future__ import annotations

from pathlib import Path

from arch_config.core.models import DesiredState
from arch_config.core.resolver import resolve

VALID_FILE_MODES = {"link", "copy", "template"}
VALID_HOOK_RUNS = {"pre", "post"}
VALID_HOOK_KINDS = {
    "generator",
    "managed-external-files",
    "external-state",
    "sync",
}


def validate_state(state: DesiredState) -> tuple[int, list[str], list[str]]:
    errors: list[str] = []
    warnings: list[str] = []

    seen_targets: dict[str, str] = {}

    for item in state.files:
        if not item.source_abs.exists():
            errors.append(f"missing source for {item.feature}: {item.source_abs}")

        old = seen_targets.get(item.target)
        if old:
            warnings.append(f"duplicate target {item.target}: {old} and {item.feature}")

        seen_targets[item.target] = item.feature

        if item.mode not in VALID_FILE_MODES:
            errors.append(f"bad file mode for {item.target}: {item.mode}")

    for item in state.hooks:
        if item.run not in VALID_HOOK_RUNS:
            errors.append(f"bad hook run for {item.feature}:{item.name}: {item.run}")

        if item.kind not in VALID_HOOK_KINDS:
            errors.append(f"bad hook kind for {item.feature}:{item.name}: {item.kind}")

        script = Path(item.script_abs)
        if not script.exists():
            errors.append(f"missing hook script for {item.feature}:{item.name}: {script}")

        if item.cleanup:
            cleanup = Path(item.cleanup_abs)
            if not cleanup.exists():
                errors.append(
                    f"missing hook cleanup for {item.feature}:{item.name}: {cleanup}"
                )

    return (1 if errors else 0), errors, warnings


def validate(profile: str) -> tuple[int, list[str], list[str]]:
    try:
        state = resolve(profile)
    except Exception as exc:
        return 1, [str(exc)], []

    return validate_state(state)
