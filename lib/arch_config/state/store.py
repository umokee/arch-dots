from __future__ import annotations

import json
import os
import shutil
from contextlib import suppress
from pathlib import Path
from typing import Any

from arch_config.paths import ROOT

STATE_DIR = ROOT / "state"


def profile_state_dir(profile: str) -> Path:
    return STATE_DIR / profile


def pending_state_dir(profile: str) -> Path:
    return profile_state_dir(profile) / "pending"


def state_json_path(
    profile: str,
    name: str,
    *,
    pending: bool = False,
) -> Path:
    if pending:
        return pending_state_dir(profile) / name

    return profile_state_dir(profile) / name


def reset_pending_state(
    profile: str,
    *,
    dry_run: bool,
) -> None:
    path = pending_state_dir(profile)
    print(f"reset pending state {path}")

    if dry_run:
        return

    if path.exists():
        shutil.rmtree(path)

    path.mkdir(parents=True, exist_ok=True)


def save_json_state(
    profile: str,
    name: str,
    state: dict[str, Any],
    *,
    dry_run: bool,
    pending: bool = False,
) -> None:
    path = state_json_path(profile, name, pending=pending)

    if pending:
        print(f"save pending state {path}")
    else:
        print(f"save state {path}")

    if dry_run:
        return

    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(
        json.dumps(state, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


def commit_pending_state(
    profile: str,
    names: list[str],
    *,
    dry_run: bool,
) -> None:
    pending_dir = pending_state_dir(profile)
    active_dir = profile_state_dir(profile)

    print(f"commit pending state {pending_dir} -> {active_dir}")

    if dry_run:
        return

    active_dir.mkdir(parents=True, exist_ok=True)

    for name in names:
        src = pending_dir / name
        dst = active_dir / name

        if not src.exists():
            continue

        os.replace(src, dst)

    with suppress(OSError):
        pending_dir.rmdir()
