from __future__ import annotations

import html
import re
from typing import Any

_EXPR_RE = re.compile(r"\{\{\s*(.*?)\s*\}\}", re.S)


def _lookup(data: dict[str, Any], path: str) -> Any:
    cur: Any = data
    for part in path.split("."):
        part = part.strip()
        if not part:
            continue
        if isinstance(cur, dict) and part in cur:
            cur = cur[part]
        else:
            raise KeyError(path)
    return cur


def _apply_filter(value: Any, filter_expr: str) -> Any:
    filter_expr = filter_expr.strip()
    if filter_expr.startswith("join"):
        m = re.match(r"join\((['\"])(.*?)\1\)", filter_expr)
        sep = m.group(2) if m else ""
        if isinstance(value, (list, tuple)):
            return sep.join(str(item) for item in value)
        return str(value)
    if filter_expr == "lower":
        return str(value).lower()
    if filter_expr == "upper":
        return str(value).upper()
    if filter_expr == "quote":
        return '"' + str(value).replace('"', '\\"') + '"'
    if filter_expr == "html_escape":
        return html.escape(str(value))
    raise KeyError(filter_expr)


def eval_expr(expr: str, data: dict[str, Any]) -> str:
    parts = [part.strip() for part in expr.split("|")]
    value = _lookup(data, parts[0])
    for filter_expr in parts[1:]:
        value = _apply_filter(value, filter_expr)
    if isinstance(value, bool):
        return "true" if value else "false"
    return str(value)


def render_template_text(text: str, data: dict[str, Any]) -> str:
    def repl(match: re.Match[str]) -> str:
        expr = match.group(1)
        try:
            return eval_expr(expr, data)
        except KeyError as exc:
            raise SystemExit(
                f"Unknown template variable/filter in '{{{{ {expr} }}}}': {exc}"
            ) from exc

    return _EXPR_RE.sub(repl, text)
