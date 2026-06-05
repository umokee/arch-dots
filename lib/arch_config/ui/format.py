from __future__ import annotations

from collections import Counter
from collections.abc import Iterable

from arch_config.ui.console import print_markup
from arch_config.ui.style import cyan, dim, is_verbose


def operation_group(kind: str) -> str:
    if kind.startswith("package."):
        return "packages"
    if kind.startswith("file.") or kind.startswith("mount."):
        return "files"
    if kind.startswith("systemd."):
        return "systemd"
    if kind.startswith("hook."):
        return "hooks"
    if kind.startswith("cleanup."):
        return "cleanup"
    if kind.startswith("state."):
        return "state"
    return kind.split(".", 1)[0]


def operation_group_counts(kinds: Iterable[str]) -> list[tuple[str, int]]:
    counts = Counter(operation_group(kind) for kind in kinds)
    preferred = ["packages", "files", "systemd", "hooks", "cleanup", "state"]
    result: list[tuple[str, int]] = []

    for key in preferred:
        if key in counts:
            result.append((key, counts.pop(key)))

    result.extend(sorted(counts.items()))
    return result


def print_operation_step(index: int, total: int, kind: str, scope: str, title: str) -> None:
    if not is_verbose() and operation_group(kind) in {"files", "state"}:
        return
    print(f"{dim(f'[{index}/{total}]')} {cyan(kind):<33} {dim(scope):<13} {title}")


def print_file_action(action: str, target: object, source: object | None = None) -> None:
    if not is_verbose():
        return

    if source is None:
        print_markup(f"{dim(action)} {target}")
    else:
        print_markup(f"{dim(action)} {target} -> {source}")
