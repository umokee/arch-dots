from __future__ import annotations

from arch_config.commands.common import profile_from_args
from arch_config.engine import print_plan


def cmd_plan(args) -> int:
    print_plan(profile_from_args(args))
    return 0
