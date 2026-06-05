"""CLI command handlers for archctl."""

from arch_config.commands.diff import cmd_diff
from arch_config.commands.generate import cmd_check_generated, cmd_generate, cmd_generated
from arch_config.commands.plan import cmd_plan
from arch_config.commands.prune import cmd_prune
from arch_config.commands.self_test import cmd_self_test
from arch_config.commands.switch import cmd_switch
from arch_config.commands.validate import cmd_validate
from arch_config.commands.vars import cmd_vars

__all__ = [
    "cmd_check_generated",
    "cmd_diff",
    "cmd_generate",
    "cmd_generated",
    "cmd_plan",
    "cmd_prune",
    "cmd_self_test",
    "cmd_switch",
    "cmd_validate",
    "cmd_vars",
]
