from __future__ import annotations

import os
import shutil
import tempfile
from pathlib import Path
from typing import Any

from arch_config.model import DirItem, FileItem, LinkItem
from arch_config.render.files import render_file
from arch_config.system.shell import run_root
from arch_config.ui import print_file_action


def config_home(config: dict[str, Any]) -> Path:
    raw_home = config.get("_home") or config.get("home") or Path.home()
    return Path(str(raw_home)).expanduser().resolve(strict=False)


def is_inside_or_same(path: Path, base: Path) -> bool:
    path_abs = path.expanduser().resolve(strict=False)
    base_abs = base.expanduser().resolve(strict=False)

    try:
        path_abs.relative_to(base_abs)
        return True
    except ValueError:
        return False


def is_system_target(target: Path, home: Path) -> bool:
    if not target.is_absolute():
        return False

    return not is_inside_or_same(target, home)


def write_home_or_system(
    target: Path,
    content: str,
    permissions: str,
    owner: str,
    group: str,
    *,
    dry_run: bool,
    home: Path | None = None,
) -> None:
    state_home = home or Path.home()
    is_system = is_system_target(target, state_home)

    if is_system:
        with tempfile.TemporaryDirectory(prefix="archctl-file-") as tmp_dir:
            tmp = Path(tmp_dir) / target.name
            tmp.write_text(content, encoding="utf-8")

            run_root(
                [
                    "install",
                    "-D",
                    "-m",
                    permissions,
                    "-o",
                    owner,
                    "-g",
                    group,
                    str(tmp),
                    str(target),
                ],
                dry_run=dry_run,
            )

        return

    print_file_action("write", target)

    if dry_run:
        return

    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(content, encoding="utf-8")
    os.chmod(target, int(permissions, 8))


def replace_with_symlink(target: Path, source: Path, *, dry_run: bool) -> None:
    print_file_action("link", target, source)

    if dry_run:
        return

    target.parent.mkdir(parents=True, exist_ok=True)

    if target.is_symlink() or target.exists():
        if target.is_dir() and not target.is_symlink():
            backup = target.with_name(target.name + ".backup-archctl")
            if backup.exists():
                shutil.rmtree(backup)
            target.rename(backup)
        else:
            target.unlink()

    target.symlink_to(source, target_is_directory=source.is_dir())


def ensure_dir(target: Path, permissions: str, *, dry_run: bool) -> None:
    print_file_action("mkdir", target)

    if dry_run:
        return

    if target.is_symlink():
        target.unlink()

    if target.exists():
        if not target.is_dir():
            target.unlink()
            target.mkdir(parents=True, exist_ok=True)
        os.chmod(target, int(permissions, 8))
        return

    target.mkdir(parents=True, exist_ok=True)
    os.chmod(target, int(permissions, 8))


def ensure_system_dir(target: Path, permissions: str, *, dry_run: bool) -> None:
    run_root(
        [
            "sh",
            "-c",
            'target="$1"; mode="$2"; '
            'if [ -L "$target" ]; then rm -f -- "$target"; fi; '
            'if [ -e "$target" ] && [ ! -d "$target" ]; then rm -f -- "$target"; fi; '
            'install -d -m "$mode" -- "$target"',
            "archctl-ensure-dir",
            str(target),
            permissions,
        ],
        dry_run=dry_run,
    )


def apply_dir(item: DirItem, config: dict[str, Any], *, dry_run: bool) -> None:
    home = config_home(config)

    if is_system_target(item.target_abs, home):
        ensure_system_dir(item.target_abs, item.permissions, dry_run=dry_run)
    else:
        ensure_dir(item.target_abs, item.permissions, dry_run=dry_run)


def apply_file(item: FileItem, config: dict[str, Any], *, dry_run: bool) -> None:
    if item.mode == "link":
        replace_with_symlink(item.target_abs, item.source_abs, dry_run=dry_run)
        return

    content = render_file(item, config)
    permissions = "755" if item.executable else item.permissions

    write_home_or_system(
        item.target_abs,
        content,
        permissions,
        item.owner,
        item.group,
        dry_run=dry_run,
        home=config_home(config),
    )


def apply_link(item: LinkItem, *, dry_run: bool) -> None:
    replace_with_symlink(item.target_abs, item.source_abs, dry_run=dry_run)
