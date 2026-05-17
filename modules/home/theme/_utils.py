from __future__ import annotations

from pathlib import Path

from shared.lib import ROOT, generated_home_file
from shared.lib import dot_dir as _dot_dir
from shared.lib import dot_file as _dot_file


def dot_source_exists(source_rel: str) -> bool:
    return (Path(ROOT) / "dots" / "home" / source_rel.lstrip("/")).exists()


def dot_file(
    username: str,
    target_rel: str,
    source_rel: str | None = None,
    mode: int = 0o644,
) -> None:
    source = source_rel or target_rel

    if not dot_source_exists(source):
        print(f"[home] skip missing dotfile: dots/home/{source}")
        return

    _dot_file(username, target_rel, source, mode=mode)


def dot_dir(
    username: str,
    target_rel: str,
    source_rel: str | None = None,
) -> None:
    source = source_rel or target_rel

    if not dot_source_exists(source):
        print(f"[home] skip missing dotdir: dots/home/{source}")
        return

    _dot_dir(username, target_rel, source)


def generated_file(
    username: str,
    target_rel: str,
    content: str,
    mode: int = 0o644,
) -> None:
    generated_home_file(username, target_rel, content, mode=mode)
