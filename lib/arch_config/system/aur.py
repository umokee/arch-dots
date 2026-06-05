from __future__ import annotations

from arch_config.paths import ROOT
from arch_config.system.shell import run


def install_aur_package(
    package: str,
    *,
    helper: str,
    dry_run: bool,
) -> None:
    run(
        [helper, "-S", "--needed", "--noconfirm", package],
        dry_run=dry_run,
        cwd=ROOT,
    )


def install_aur_packages(
    packages: list[str],
    *,
    helper: str,
    dry_run: bool,
) -> None:
    for package in packages:
        install_aur_package(package, helper=helper, dry_run=dry_run)
