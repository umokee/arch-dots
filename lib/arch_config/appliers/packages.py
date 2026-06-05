from __future__ import annotations

from arch_config.core.models import SwitchPlan
from arch_config.system.aur import install_aur_package, install_aur_packages
from arch_config.system.pacman import (
    install_native_packages,
    prune_remove_list,
    remove_packages,
)


def apply_packages(plan: SwitchPlan) -> None:
    install_native_packages(plan.missing_pacman, dry_run=plan.options.dry_run)

    if plan.options.with_aur:
        install_aur_packages(
            plan.missing_aur,
            helper=plan.options.helper,
            dry_run=plan.options.dry_run,
        )
    elif plan.state.aur:
        print("AUR skipped. Use --aur to install AUR packages.")


def apply_pacman_packages(packages: list[str], *, dry_run: bool) -> None:
    install_native_packages(packages, dry_run=dry_run)


def apply_aur_package(package: str, *, helper: str, dry_run: bool) -> None:
    install_aur_package(package, helper=helper, dry_run=dry_run)


def apply_strict_prune(plan: SwitchPlan) -> None:
    remove_packages(
        prune_remove_list(plan.strict_prune_plan), dry_run=plan.options.dry_run
    )
