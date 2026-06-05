from __future__ import annotations

from arch_config.commands.common import profile_from_args
from arch_config.engine import switch


def cmd_switch(args) -> int:
    return switch(
        profile_from_args(args),
        with_aur=args.aur,
        helper=args.helper,
        dry_run=args.dry_run,
        yes=args.yes,
        strict=args.strict,
        prune_aur=not args.no_prune_aur,
        include_orphans=args.remove_orphans,
        prune_files=not args.no_prune_files,
    )
