"""Small ANSI terminal UI built only on the Python standard library."""

from arch_config.ui.console import (
    print_command,
    print_error,
    print_header,
    print_info,
    print_markup,
    print_muted,
    print_section,
    print_success,
    print_warning,
)
from arch_config.ui.format import (
    operation_group,
    operation_group_counts,
    print_file_action,
    print_operation_step,
)
from arch_config.ui.style import Style, escape, is_verbose
from arch_config.ui.table import print_key_values, print_list, print_table

__all__ = [
    "Style",
    "escape",
    "is_verbose",
    "operation_group",
    "operation_group_counts",
    "print_command",
    "print_error",
    "print_file_action",
    "print_header",
    "print_info",
    "print_key_values",
    "print_list",
    "print_markup",
    "print_muted",
    "print_operation_step",
    "print_section",
    "print_success",
    "print_table",
    "print_warning",
]
