from __future__ import annotations

from arch_config.commands.common import profile_from_args
from arch_config.engine import print_plan, print_prune_plan, print_state_diff
from arch_config.ui import print_section, print_warning


def cmd_diff(args) -> int:
    profile = profile_from_args(args)

    print_plan(profile)
    print_section("State cleanup preview")
    print_state_diff(profile)

    if args.strict:
        print_section("Strict package cleanup preview")
        print_warning("These packages would be removed by strict pruning.")
        print_prune_plan(
            profile,
            include_aur=not args.no_aur,
            include_orphans=args.remove_orphans,
        )

    return 0
