from __future__ import annotations


def profile_from_args(args) -> str:
    return args.profile or "desktop"
