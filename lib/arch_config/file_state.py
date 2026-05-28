from __future__ import annotations

import hashlib
import json
import os
import shutil
import subprocess
from datetime import datetime
from pathlib import Path
from typing import Any

from arch_config.model import ResolvedState
from arch_config.paths import ROOT
from arch_config.system.shell import run, run_root

STATE_DIR = ROOT / "state"
STATE_VERSION = 1

SYSTEMD_UNIT_SUFFIXES = (
    ".service",
    ".socket",
    ".timer",
    ".target",
    ".path",
    ".mount",
    ".automount",
)


def files_state_path(profile: str) -> Path:
    return STATE_DIR / profile / "files.json"


def trash_dir(profile: str) -> Path:
    return STATE_DIR / profile / "trash"


def backup_stale_file(profile: str, path: Path, *, dry_run: bool) -> Path:
    """
    Сохраняет копию stale-файла перед удалением, если он изменился руками.

    Backup создаётся в state/<profile>/trash и остаётся читаемым пользователем.
    """
    stamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    safe_name = str(path).strip("/").replace("/", "__")
    backup_path = trash_dir(profile) / stamp / safe_name

    print(f"backup modified stale file {path} -> {backup_path}")

    if dry_run:
        return backup_path

    backup_path.parent.mkdir(parents=True, exist_ok=True)

    if _is_system_path(path):
        result = subprocess.run(
            ["sudo", "cat", "--", str(path)],
            stdout=subprocess.PIPE,
            check=False,
        )

        if result.returncode != 0:
            print(f"warning: failed to backup protected file: {path}")
            return backup_path

        backup_path.write_bytes(result.stdout)
        os.chmod(backup_path, 0o600)
        return backup_path

    shutil.copy2(path, backup_path)
    return backup_path


def load_files_state(profile: str) -> dict[str, Any]:
    path = files_state_path(profile)
    if not path.exists():
        return {
            "version": STATE_VERSION,
            "profile": profile,
            "files": {},
        }

    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except Exception:
        print(f"warning: broken file state, ignoring: {path}")
        return {
            "version": STATE_VERSION,
            "profile": profile,
            "files": {},
        }


def save_files_state(
    profile: str,
    state: dict[str, Any],
    *,
    dry_run: bool,
) -> None:
    path = files_state_path(profile)
    print(f"save file state {path}")

    if dry_run:
        return

    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(
        json.dumps(state, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


def _sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def _read_file_bytes(path: Path) -> bytes | None:
    """
    Читает файл для hash.

    Обычные user-файлы читаем напрямую.
    Root/system-файлы могут быть 440/600, поэтому читаем через sudo cat.
    """
    try:
        return path.read_bytes()
    except PermissionError:
        if not _is_system_path(path):
            raise

        result = subprocess.run(
            ["sudo", "cat", "--", str(path)],
            stdout=subprocess.PIPE,
            check=False,
        )

        if result.returncode != 0:
            print(f"warning: cannot read protected file for state hash: {path}")
            return None

        return result.stdout


def managed_path_hash(path: Path) -> str | None:
    """
    Hash того, что реально лежит по target.

    Важно:
    - обычный файл хэшируется по содержимому;
    - root-файл читается через sudo, если обычное чтение запрещено;
    - symlink хэшируется по readlink target;
    - директории не хэшируются и не участвуют в удалении.
    """
    if path.is_symlink():
        return _sha256_bytes(f"symlink\0{os.readlink(path)}".encode())

    if not path.exists():
        return None

    if path.is_dir():
        return None

    data = _read_file_bytes(path)
    if data is None:
        return None

    return _sha256_bytes(b"file\0" + data)


def _is_system_path(path: Path) -> bool:
    home = str(Path.home())
    text = str(path)

    if not path.is_absolute():
        return False

    return not (text == home or text.startswith(home + "/"))


def _unit_from_target(path: Path) -> tuple[str, str] | None:
    """
    Определяет, является ли target systemd unit-файлом, который archctl
    должен перед удалением выключить.

    Возвращает:
      ("system", "xray.service")
      ("user", "quickshell.service")
    """
    name = path.name

    if not name.endswith(SYSTEMD_UNIT_SUFFIXES):
        return None

    system_dir = Path("/etc/systemd/system")
    user_dir = Path.home() / ".config/systemd/user"

    text = str(path)
    system_text = str(system_dir)
    user_text = str(user_dir)

    if text.startswith(system_text + "/"):
        return ("system", name)

    if text.startswith(user_text + "/"):
        return ("user", name)

    return None


def _add_file_entry(
    files: dict[str, Any],
    *,
    target: Path,
    feature: str,
    source: str,
    mode: str,
    kind: str,
    include_hashes: bool,
) -> None:
    # Никогда не берём под управление реальные директории.
    # Symlink на директорию — это НЕ директория, его можно безопасно unlink.
    if target.exists() and target.is_dir() and not target.is_symlink():
        return

    unit = _unit_from_target(target)
    unit_scope: str | None = None
    unit_name: str | None = None

    if unit:
        unit_scope, unit_name = unit
        kind = f"{unit_scope}-unit"

    entry: dict[str, Any] = {
        "feature": feature,
        "source": source,
        "mode": mode,
        "kind": kind,
        "unit_scope": unit_scope,
        "unit": unit_name,
    }

    if include_hashes:
        entry["sha256"] = managed_path_hash(target)
    else:
        entry["sha256"] = None

    files[str(target)] = entry


def build_files_state(
    state: ResolvedState,
    *,
    include_hashes: bool = True,
) -> dict[str, Any]:
    """
    Собирает маленький internal-state только по файлам/symlink-ам,
    которые archctl сам должен считать управляемыми.

    Директории сюда сознательно не попадают.
    """
    files: dict[str, Any] = {}

    for item in state.files:
        kind = "link" if item.mode == "link" else "file"

        _add_file_entry(
            files,
            target=item.target_abs,
            feature=item.feature,
            source=item.source,
            mode=item.mode,
            kind=kind,
            include_hashes=include_hashes,
        )

    for item in state.links:
        _add_file_entry(
            files,
            target=item.target_abs,
            feature="links",
            source=item.source,
            mode="link",
            kind="link",
            include_hashes=include_hashes,
        )

    for mount in state.mounts:
        _add_file_entry(
            files,
            target=Path("/etc/systemd/system") / mount.mount_unit,
            feature=f"mount:{mount.name}",
            source="generated mount unit",
            mode="generated",
            kind="system-unit",
            include_hashes=include_hashes,
        )

        if mount.automount:
            _add_file_entry(
                files,
                target=Path("/etc/systemd/system") / mount.automount_unit,
                feature=f"mount:{mount.name}",
                source="generated automount unit",
                mode="generated",
                kind="system-unit",
                include_hashes=include_hashes,
            )

    return {
        "version": STATE_VERSION,
        "profile": state.profile,
        "files": files,
    }


def _disable_unit(scope: str, unit: str, *, dry_run: bool) -> None:
    if scope == "system":
        run_root(
            [
                "sh",
                "-c",
                'systemctl disable --now "$1" >/dev/null 2>&1 || true',
                "archctl-disable-unit",
                unit,
            ],
            dry_run=dry_run,
        )
        return

    if scope == "user":
        run(
            [
                "sh",
                "-c",
                'systemctl --user disable --now "$1" >/dev/null 2>&1 || true',
                "archctl-disable-unit",
                unit,
            ],
            dry_run=dry_run,
        )


def _remove_file_or_symlink(path: Path, *, dry_run: bool) -> None:
    print(f"prune file {path}")

    if dry_run:
        return

    if _is_system_path(path):
        run_root(["rm", "-f", "--", str(path)], dry_run=False)
        return

    try:
        path.unlink()
    except FileNotFoundError:
        pass


def prune_stale_managed_files(
    profile: str,
    current_state: dict[str, Any],
    *,
    dry_run: bool,
    force_modified: bool = False,
) -> dict[str, list[str]]:
    """
    Автоматически удаляет мусорные managed-файлы:

    old files state - current desired files state = stale files

    Политика:
    - директории не удаляются;
    - неизвестные файлы не удаляются;
    - stale managed-файлы удаляются даже если менялись руками;
    - если stale managed-файл менялся руками, перед удалением делается backup;
    - symlink удаляется только как ссылка, target не трогается;
    - systemd unit перед удалением выключается.
    """
    old_state = load_files_state(profile)
    old_files: dict[str, Any] = dict(old_state.get("files") or {})
    current_files: dict[str, Any] = dict(current_state.get("files") or {})

    result: dict[str, list[str]] = {
        "removed": [],
        "missing": [],
        "modified_backed_up": [],
        "directories": [],
        "replaced_links": [],
    }

    if not old_files:
        print("No previous file state found. Adopting current managed files.")
        return result

    stale_targets = sorted(set(old_files) - set(current_files))

    if not stale_targets:
        print("No stale managed files.")
        return result

    print("\nStale managed files:")

    need_system_reload = False
    need_user_reload = False

    for target in stale_targets:
        path = Path(target)
        old_entry = old_files[target]

        old_kind = str(old_entry.get("kind") or "")
        old_mode = str(old_entry.get("mode") or "")
        was_link = old_kind == "link" or old_mode == "link"

        if not path.exists() and not path.is_symlink():
            print(f"  already missing: {path}")
            result["missing"].append(target)
            continue

        # Директории никогда не удаляем.
        # Важно: symlink на директорию директорией не считаем, его unlink можно.
        if path.exists() and path.is_dir() and not path.is_symlink():
            print(f"  skip directory: {path}")
            result["directories"].append(target)
            continue

        # Если archctl раньше создал symlink, а теперь на этом месте уже НЕ symlink,
        # значит пользователь заменил ссылку чем-то своим. Это уже не тот managed artifact.
        if was_link and not path.is_symlink():
            print(f"  skip replaced link target: {path}")
            result["replaced_links"].append(target)
            continue

        actual_hash = managed_path_hash(path)
        old_hash = old_entry.get("sha256")

        if old_hash and actual_hash and actual_hash != old_hash:
            # Hash больше не блокирует удаление.
            # Просто сохраняем backup для обычных файлов.
            if not path.is_symlink():
                backup_stale_file(profile, path, dry_run=dry_run)
                result["modified_backed_up"].append(target)

        unit_scope = old_entry.get("unit_scope")
        unit_name = old_entry.get("unit")

        if unit_scope and unit_name:
            print(f"  disable {unit_scope} unit: {unit_name}")
            _disable_unit(str(unit_scope), str(unit_name), dry_run=dry_run)

            if unit_scope == "system":
                need_system_reload = True
            elif unit_scope == "user":
                need_user_reload = True

        _remove_file_or_symlink(path, dry_run=dry_run)
        result["removed"].append(target)

    if need_system_reload:
        run_root(["systemctl", "daemon-reload"], dry_run=dry_run)

    if need_user_reload:
        run(["systemctl", "--user", "daemon-reload"], dry_run=dry_run)

    if result["modified_backed_up"]:
        print("\nModified stale files were backed up before removal.")
        print(f"Backups are stored in: {trash_dir(profile)}")

    return result
