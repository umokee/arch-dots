from __future__ import annotations

import os
import re
import shutil
import sys

TRUE_VALUES = {"1", "true", "yes", "on"}
PLAIN_ENV = os.environ.get("ARCHCTL_PLAIN", "").lower() in TRUE_VALUES
NO_COLOR = "NO_COLOR" in os.environ
COLOR_MODE = os.environ.get("ARCHCTL_COLOR", "auto").lower()
ANSI_RE = re.compile(r"\x1b\[[0-9;]*m")
MARKUP_RE = re.compile(r"\[/?[a-zA-Z][^\]]*\]")


class Style:
    reset = "\033[0m"
    bold = "\033[1m"
    dim = "\033[2m"
    red = "\033[31m"
    green = "\033[32m"
    yellow = "\033[33m"
    blue = "\033[34m"
    magenta = "\033[35m"
    cyan = "\033[36m"
    gray = "\033[90m"


def supports_color() -> bool:
    if PLAIN_ENV or NO_COLOR:
        return False

    if COLOR_MODE in {"always", "force"}:
        return True

    if COLOR_MODE in {"never", "none", "off"}:
        return False

    return sys.stdout.isatty() and os.environ.get("TERM", "") != "dumb"


USE_COLOR = supports_color()


def is_verbose() -> bool:
    return os.environ.get("ARCHCTL_VERBOSE", "").lower() in TRUE_VALUES


def escape(value: object) -> str:
    """Compatibility helper kept for call sites previously using rich.escape."""
    return str(value)


def strip_ansi(value: object) -> str:
    return ANSI_RE.sub("", str(value))


def strip_markup(value: object) -> str:
    return MARKUP_RE.sub("", str(value))


def visible_len(value: object) -> int:
    return len(strip_ansi(str(value)))


def terminal_width(default: int = 100) -> int:
    return shutil.get_terminal_size((default, 24)).columns


def paint(value: object, *styles: str) -> str:
    text = str(value)
    if not USE_COLOR or not styles:
        return text
    return "".join(styles) + text + Style.reset


def dim(value: object) -> str:
    return paint(value, Style.dim)


def bold(value: object) -> str:
    return paint(value, Style.bold)


def cyan(value: object) -> str:
    return paint(value, Style.cyan)


def green(value: object) -> str:
    return paint(value, Style.green)


def yellow(value: object) -> str:
    return paint(value, Style.yellow)


def red(value: object) -> str:
    return paint(value, Style.red)


def blue(value: object) -> str:
    return paint(value, Style.blue)


def clip(value: object, width: int) -> str:
    text = str(value)
    if width <= 0:
        return ""
    if visible_len(text) <= width:
        return text
    plain = strip_ansi(text)
    if width <= 1:
        return "…"[:width]
    return plain[: max(0, width - 1)] + "…"
