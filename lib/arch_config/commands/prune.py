from __future__ import annotations

from arch_config.commands.common import profile_from_args
from arch_config.engine import apply_prune_plan, print_prune_plan


def cmd_prune(args) -> int:
    if args.apply:
        return apply_prune_plan(
            profile_from_args(args),
            include_aur=not args.no_aur,
            include_orphans=args.remove_orphans,
            dry_run=args.dry_run,
            yes=args.yes,
        )

    print_prune_plan(
        profile_from_args(args),
        include_aur=not args.no_aur,
        include_orphans=args.remove_orphans,
    )
    return 0
