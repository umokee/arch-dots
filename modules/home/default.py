from __future__ import annotations

from collections.abc import Callable
from importlib import import_module
from types import ModuleType

HOME_MODULES: list[str] = [
    "modules.home.base.default",
    "modules.home.shell.default",
    "modules.home.theme.default",
    "modules.home.workspace.default",
    "modules.home.services.default",
    "modules.home.programs.default",
]


def apply(conf: dict, helpers) -> None:
    for module_path in HOME_MODULES:
        module = _try_import(module_path)
        if module is None:
            continue

        apply_func: Callable[[dict, object], None] | None = getattr(
            module, "apply", None
        )
        if apply_func is None:
            raise RuntimeError(
                f"Home module '{module_path}' has no apply(conf, helpers) function"
            )

        apply_func(conf, helpers)


def _try_import(module_path: str) -> ModuleType | None:
    try:
        return import_module(module_path)
    except ModuleNotFoundError as error:
        if error.name == module_path:
            return None
        raise
