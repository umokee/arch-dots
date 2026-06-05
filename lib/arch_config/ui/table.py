from __future__ import annotations

from collections.abc import Iterable, Sequence

from arch_config.ui.console import print_muted, print_section
from arch_config.ui.style import clip, cyan, dim, is_verbose, terminal_width, visible_len


def print_key_values(title: str, rows: Iterable[tuple[str, object]]) -> None:
    data = [(str(key), str(value)) for key, value in rows]
    print_section(title)
    width = max((len(key) for key, _ in data), default=0)
    for key, value in data:
        print(f"{cyan(key):<{width + 9}} {value}")


def print_table(
    title: str,
    columns: Sequence[str],
    rows: Iterable[Sequence[object]],
    *,
    max_rows: int | None = None,
) -> None:
    data = [[str(cell) for cell in row] for row in rows]
    truncated = False

    if max_rows is not None and len(data) > max_rows:
        data = data[:max_rows]
        truncated = True

    print_section(title)
    if not data:
        print(dim("(empty)"))
        return

    term_width = max(40, terminal_width())
    widths = [len(str(column)) for column in columns]

    for row in data:
        for index, cell in enumerate(row):
            widths[index] = max(widths[index], min(visible_len(cell), 80))

    padding = 2 * (len(widths) - 1)
    total = sum(widths) + padding
    if total > term_width:
        overflow = total - term_width
        while overflow > 0 and max(widths) > 18:
            index = max(range(len(widths)), key=widths.__getitem__)
            widths[index] -= 1
            overflow -= 1

    header = "  ".join(str(col).ljust(widths[index]) for index, col in enumerate(columns))
    print(cyan(header))
    print(dim("  ".join("-" * width for width in widths)))

    for row in data:
        clipped = [clip(cell, widths[index]) for index, cell in enumerate(row)]
        print("  ".join(clipped[index].ljust(widths[index]) for index in range(len(widths))))

    if truncated:
        print_muted(f"shown first {max_rows} rows; set ARCHCTL_VERBOSE=1 to show all")


def print_list(title: str, items: Sequence[object], *, marker: str = "+", max_items: int = 40) -> None:
    values = [str(item) for item in items]
    if not values:
        return

    limit = None if is_verbose() else max_items
    shown = values if limit is None else values[:limit]

    print_section(title)
    for item in shown:
        print(f"  {marker} {item}")

    if limit is not None and len(values) > limit:
        print_muted(f"and {len(values) - limit} more; set ARCHCTL_VERBOSE=1 to show all")
