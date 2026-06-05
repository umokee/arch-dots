from __future__ import annotations

import json
from pathlib import Path
from typing import Any

from arch_config.model import ResolvedState, SystemdItem
from arch_config.paths import ROOT
from arch_config.state.store import save_json_state, state_json_path
from arch_config.system.shell import run, run_root

STATE_DIR = ROOT / "state"
STATE_VERSION = 1

VALID_SCOPES = {"system", "user"}


def systemd_state_path(profile: str, *, pending: bool = False) -> Path:
    return state_json_path(profile, "systemd.json", pending=pending)


def _unit_key(entry: dict[str, Any]) -> str:
    scope = str(entry.get("scope") or "")
    unit = str(entry.get("unit") or "")
    return f"{scope}:{unit}"


def _item_to_entry(item: SystemdItem) -> dict[str, Any]:
    return {
        "feature": item.feature,
        "scope": item.scope,
        "unit": item.unit,
        "enable": item.enable,
        "start": item.start,
    }


def build_systemd_state(state: ResolvedState) -> dict[str, Any]:
    units: dict[str, Any] = {}

    for item in state.systemd:
        if item.scope not in VALID_SCOPES:
            continue

        # Если unit явно не надо ни enable, ни start,
        # то он не считается активным desired-state.
        if not item.enable and not item.start:
            continue

        entry = _item_to_entry(item)
        key = _unit_key(entry)

        # Если один и тот же unit объявлен в нескольких feature,
        # он всё равно должен считаться одним desired unit.
        # Важно: пока хотя бы один feature оставляет unit в desired-state,
        # stale-cleanup его не выключит.
        if key in units:
            old = units[key]
            old_features = old.get("features") or [old.get("feature")]
            old_features = [str(x) for x in old_features if x]

            if item.feature not in old_features:
                old_features.append(item.feature)

            old["features"] = old_features
            old["feature"] = ",".join(old_features)
            old["enable"] = bool(old.get("enable")) or item.enable
            old["start"] = bool(old.get("start")) or item.start
            continue

        entry["features"] = [item.feature]
        units[key] = entry

    return {
        "version": STATE_VERSION,
        "profile": state.profile,
        "units": units,
    }


def load_systemd_state(profile: str) -> dict[str, Any]:
    path = systemd_state_path(profile)

    if not path.exists():
        return {
            "version": STATE_VERSION,
            "profile": profile,
            "units": {},
        }

    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except Exception:
        print(f"warning: broken systemd state, ignoring: {path}")
        return {
            "version": STATE_VERSION,
            "profile": profile,
            "units": {},
        }


def save_systemd_state(
    profile: str,
    state: dict[str, Any],
    *,
    dry_run: bool,
    pending: bool = False,
) -> None:
    save_json_state(
        profile,
        "systemd.json",
        state,
        dry_run=dry_run,
        pending=pending,
    )


def stale_systemd_units(
    profile: str,
    current_state: dict[str, Any],
) -> list[dict[str, Any]]:
    old_state = load_systemd_state(profile)

    old_units: dict[str, Any] = dict(old_state.get("units") or {})
    current_units: dict[str, Any] = dict(current_state.get("units") or {})

    if not old_units:
        return []

    result: list[dict[str, Any]] = []

    for key in sorted(set(old_units) - set(current_units)):
        raw = old_units[key]
        if isinstance(raw, dict):
            result.append(raw)

    return result


def print_stale_systemd_units(entries: list[dict[str, Any]]) -> None:
    if not entries:
        return

    print("Stale systemd units cleanup preview:")

    for entry in entries:
        feature = str(entry.get("feature") or "?")
        scope = str(entry.get("scope") or "?")
        unit = str(entry.get("unit") or "?")
        enable = bool(entry.get("enable"))
        start = bool(entry.get("start"))

        print(f"  - {scope}:{unit}")
        print(f"    old feature: {feature}")

        if enable and start:
            print("    action: disable --now")
        elif enable:
            print("    action: disable")
        elif start:
            print("    action: stop")
        else:
            print("    action: no-op")


def _disable_or_stop_unit(
    scope: str,
    unit: str,
    *,
    enable: bool,
    start: bool,
    dry_run: bool,
) -> None:
    if scope == "system":
        base = ["systemctl"]
        runner = run_root
    elif scope == "user":
        base = ["systemctl", "--user"]
        runner = run
    else:
        print(f"  warning: bad systemd scope for stale unit: {scope}:{unit}")
        return

    if enable and start:
        cmd = [*base, "disable", "--now", unit]
    elif enable:
        cmd = [*base, "disable", unit]
    elif start:
        cmd = [*base, "stop", unit]
    else:
        return

    # Stale cleanup should not break the whole switch if a package was already removed
    # or the unit disappeared. This is cleanup, not the main apply path.
    if scope == "system":
        runner(
            [
                "sh",
                "-c",
                '"$@" >/dev/null 2>&1 || true',
                "archctl-systemd-cleanup",
                *cmd,
            ],
            dry_run=dry_run,
        )
    else:
        runner(
            [
                "sh",
                "-c",
                '"$@" >/dev/null 2>&1 || true',
                "archctl-systemd-cleanup",
                *cmd,
            ],
            dry_run=dry_run,
        )


def run_stale_systemd_cleanup(
    entries: list[dict[str, Any]],
    *,
    dry_run: bool,
) -> None:
    if not entries:
        return

    print("\nStale systemd units:")

    for entry in entries:
        feature = str(entry.get("feature") or "?")
        scope = str(entry.get("scope") or "")
        unit = str(entry.get("unit") or "")
        enable = bool(entry.get("enable"))
        start = bool(entry.get("start"))

        if not scope or not unit:
            continue

        print(f"  cleanup {scope}:{unit} from {feature}")

        _disable_or_stop_unit(
            scope,
            unit,
            enable=enable,
            start=start,
            dry_run=dry_run,
        )
