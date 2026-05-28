from __future__ import annotations

from pathlib import Path
from typing import Any

from arch_config.config.loader import load_feature, load_profile
from arch_config.model import (
    DirItem,
    FileItem,
    HookItem,
    LinkItem,
    MountItem,
    ResolvedState,
    SystemdItem,
)
from arch_config.paths import HOOKS_DIR


def _unique(items: list[str]) -> list[str]:
    result: list[str] = []
    seen: set[str] = set()
    for item in items:
        if item and item not in seen:
            seen.add(item)
            result.append(item)
    return result


def _home() -> Path:
    return Path.home()


def expand_target(value: str) -> Path:
    if value.startswith("~/"):
        return _home() / value[2:]
    if value == "~":
        return _home()
    return Path(value)


def _condition_ok(
    item: dict[str, Any], profile: dict[str, Any], enabled_features: set[str]
) -> bool:
    absent = item.get("condition_feature_absent")
    if isinstance(absent, str) and absent in enabled_features:
        return False
    present = item.get("condition_feature_present")
    if isinstance(present, str) and present not in enabled_features:
        return False
    mt = item.get("condition_machine_type")
    if isinstance(mt, str) and profile.get("machine_type") != mt:
        return False
    return True


def _append_cachyos(profile: dict[str, Any], pacman: list[str]) -> None:
    cachyos = profile.get("cachyos", {})
    if not isinstance(cachyos, dict) or not cachyos.get("bootstrap_repos", False):
        return
    pacman += [
        "cachyos-keyring",
        "cachyos-mirrorlist",
        "cachyos-v3-mirrorlist",
        "cachyos-v4-mirrorlist",
        "cachyos-rate-mirrors",
    ]
    for key in ["kernel", "kernel_headers"]:
        value = cachyos.get(key)
        if value:
            pacman.append(str(value))
    pacman += [str(item) for item in cachyos.get("kernel_extra_packages", [])]
    if cachyos.get("install_settings", True):
        pacman += ["cachyos-hooks", "cachyos-settings", "cachyos-micro-settings"]
    if profile.get("fallback_kernel", True):
        pacman += ["linux", "linux-headers", "nvidia-open"]


def _mounts(profile: dict[str, Any]) -> list[MountItem]:
    result: list[MountItem] = []
    for raw in profile.get("mounts", []) or []:
        if not isinstance(raw, dict):
            continue
        opts = raw.get("options", ["defaults", "noatime"])
        if isinstance(opts, str):
            opts = [item.strip() for item in opts.split(",") if item.strip()]
        result.append(
            MountItem(
                name=str(raw.get("name") or Path(str(raw.get("where", "mount"))).name),
                what=str(raw["what"]),
                where=str(raw["where"]),
                type=str(raw.get("type", "auto")),
                options=tuple(str(item) for item in opts),
                automount=bool(raw.get("automount", True)),
                timeout_idle_sec=str(raw.get("timeout_idle_sec", "600")),
                directory_mode=str(raw.get("directory_mode", "755")),
                wanted_by=str(raw.get("wanted_by", "multi-user.target")),
            )
        )
    return result


def hook_script_path(feature_root: Path, script: str) -> Path:
    """
    Новый путь:
      features/<group>/<name>/hooks/<script>

    Старый fallback:
      hooks/<script>
    """
    local = feature_root / "hooks" / script

    if local.exists():
        return local

    return HOOKS_DIR / script


def resolve(profile_name: str) -> ResolvedState:
    profile = load_profile(profile_name)
    enabled_features = [str(item) for item in profile.get("features", [])]
    enabled_set = set(enabled_features)

    state = ResolvedState(
        profile=profile_name, config=profile, features=enabled_features
    )
    _append_cachyos(profile, state.pacman)

    for mount in _mounts(profile):
        state.mounts.append(mount)
        state.systemd.append(
            SystemdItem(
                scope="system", unit=mount.enabled_unit, enable=True, start=True
            )
        )

    for feature_id in enabled_features:
        feature = load_feature(feature_id)
        data = feature.data
        packages = data.get("packages", {})
        if isinstance(packages, dict):
            state.pacman += [str(item) for item in packages.get("pacman", [])]
            state.aur += [str(item) for item in packages.get("aur", [])]

        for raw in data.get("dirs", []) or []:
            if not isinstance(raw, dict) or not _condition_ok(
                raw, profile, enabled_set
            ):
                continue
            target = str(raw["target"])
            state.dirs.append(
                DirItem(
                    target=target,
                    target_abs=expand_target(target),
                    permissions=str(raw.get("permissions", "755")),
                )
            )

        for raw in data.get("files", []) or []:
            if not isinstance(raw, dict) or not _condition_ok(
                raw, profile, enabled_set
            ):
                continue
            source = str(raw["source"])
            target = str(raw["target"])
            mode = str(raw.get("mode", "copy"))
            source_abs = (feature.root / source).resolve()
            state.files.append(
                FileItem(
                    feature=feature_id,
                    source=source,
                    source_abs=source_abs,
                    target=target,
                    target_abs=expand_target(target),
                    mode=mode,
                    type=str(raw.get("type", "file")),
                    owner=str(raw.get("owner", "root")),
                    group=str(raw.get("group", "root")),
                    permissions=str(raw.get("permissions", "644")),
                    executable=bool(raw.get("executable", False)),
                )
            )

        for raw in data.get("links", []) or []:
            if not isinstance(raw, dict) or not _condition_ok(
                raw, profile, enabled_set
            ):
                continue
            source = str(raw["source"])
            target = str(raw["target"])
            state.links.append(
                LinkItem(
                    source=source,
                    source_abs=expand_target(source),
                    target=target,
                    target_abs=expand_target(target),
                )
            )

        systemd = data.get("systemd", {})
        if isinstance(systemd, dict):
            for scope in ["system", "user"]:
                for raw in systemd.get(scope, []) or []:
                    if not isinstance(raw, dict) or not _condition_ok(
                        raw, profile, enabled_set
                    ):
                        continue
                    state.systemd.append(
                        SystemdItem(
                            scope=scope,
                            unit=str(raw["unit"]),
                            enable=bool(raw.get("enable", True)),
                            start=bool(raw.get("start", True)),
                        )
                    )

        for raw in data.get("hooks", []) or []:
            if not isinstance(raw, dict) or not _condition_ok(
                raw, profile, enabled_set
            ):
                continue

            script = str(raw["script"])
            cleanup = str(raw.get("cleanup", "") or "")

            script_abs = hook_script_path(feature.root, script)
            cleanup_abs = hook_script_path(feature.root, cleanup) if cleanup else None

            state.hooks.append(
                HookItem(
                    feature=feature_id,
                    name=str(raw["name"]),
                    script=script,
                    script_abs=str(script_abs),
                    run=str(raw.get("run", "post")),
                    kind=str(raw.get("kind", "external-state")),
                    cleanup=cleanup,
                    cleanup_abs=str(cleanup_abs) if cleanup_abs else "",
                    note=str(raw.get("note", "") or ""),
                )
            )

    state.pacman = _unique(state.pacman)
    state.aur = _unique(state.aur)

    return state
