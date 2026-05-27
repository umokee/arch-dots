from __future__ import annotations

import os
import subprocess
from pathlib import Path


def run(cmd: list[str], *, dry_run: bool = False, cwd: Path | None = None) -> None:
    print("+ " + " ".join(cmd))
    if dry_run:
        return
    subprocess.run(cmd, check=True, cwd=str(cwd) if cwd else None)


def run_root(cmd: list[str], *, dry_run: bool = False, cwd: Path | None = None) -> None:
    if os.geteuid() == 0:
        run(cmd, dry_run=dry_run, cwd=cwd)
    else:
        run(["sudo", *cmd], dry_run=dry_run, cwd=cwd)
