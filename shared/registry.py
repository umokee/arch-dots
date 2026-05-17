from __future__ import annotations

from collections.abc import Callable
from dataclasses import dataclass
from importlib import import_module
from types import ModuleType


@dataclass(frozen=True)
class ModuleSpec:
    group: str
    name: str
    module: str
    always: bool = False
    description: str = ""


def _load_module(module_path: str) -> ModuleType:
    return import_module(module_path)


def _is_enabled(spec: ModuleSpec, helpers) -> bool:
    if spec.always:
        return True

    return helpers.has_in(spec.group, spec.name)


def _apply_spec(spec: ModuleSpec, conf: dict, helpers) -> None:
    if not _is_enabled(spec, helpers):
        return

    module = _load_module(spec.module)

    apply_func: Callable[[dict, object], None] | None = getattr(module, "apply", None)

    if apply_func is None:
        raise RuntimeError(
            f"Module '{spec.module}' has no apply(conf, helpers) function"
        )

    apply_func(conf, helpers)


HOME_MODULES: list[ModuleSpec] = [
    ModuleSpec(
        group="base",
        name="users",
        module="modules.home.base",
        description="Home base: env, XDG dirs, user scripts",
    ),
    ModuleSpec(
        group="programs",
        name="terminal",
        module="modules.home.terminal",
        description="Foot terminal configuration",
    ),
    ModuleSpec(
        group="programs",
        name="shell",
        module="modules.home.shell",
        description="Fish, Starship, Tmux shell layer",
    ),
]


def apply_home_modules(conf: dict, helpers) -> None:
    for spec in HOME_MODULES:
        _apply_spec(spec, conf, helpers)
