from __future__ import annotations

from typing import Any

from arch_config.model import FileItem
from arch_config.render.template import render_template_text


def render_file(item: FileItem, config: dict[str, Any]) -> str:
    if item.mode == "template":
        return render_template_text(item.source_abs.read_text(encoding="utf-8"), config)

    if item.type == "dir":
        return f"# directory link/copy: {item.source_abs}\n"

    return item.source_abs.read_text(encoding="utf-8")
