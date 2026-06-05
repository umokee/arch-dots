from __future__ import annotations

import shlex
from collections.abc import Sequence

from arch_config.ui.style import bold, cyan, dim, green, red, strip_markup, yellow


def print_markup(text: str = "") -> None:
    print(strip_markup(text))


def print_header(title: str, subtitle: str | None = None) -> None:
    print()
    line = f"== {title} =="
    print(cyan(bold(line)))
    if subtitle:
        print(dim(subtitle))


def print_section(title: str) -> None:
    print()
    print(dim(f"-- {title} --"))


def print_success(message: str) -> None:
    print(f"{green('✓')} {message}")


def print_warning(message: str) -> None:
    print(f"{yellow('!')} {message}")


def print_error(message: str) -> None:
    print(f"{red('x')} {message}")


def print_info(message: str) -> None:
    print(f"{cyan('•')} {message}")


def print_muted(message: str) -> None:
    print(dim(message))


def print_command(cmd: Sequence[str]) -> None:
    rendered = shlex.join([str(item) for item in cmd])
    print(f"{dim('$')} {bold(rendered)}")
