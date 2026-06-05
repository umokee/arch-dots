from __future__ import annotations

from arch_config.commands.common import profile_from_args
from arch_config.engine import validate, write_generated
from arch_config.paths import PROFILES_DIR
from arch_config.ui import print_error, print_success


def cmd_self_test(args) -> int:
    profiles = (
        [profile.stem for profile in PROFILES_DIR.glob("*.toml")]
        if args.all_profiles
        else [profile_from_args(args)]
    )

    failed = 0
    for profile in profiles:
        code, errors, warnings = validate(profile)
        if code:
            failed += 1
            print_error(profile)
            for error in errors:
                print(f"  - {error}")
        else:
            print_success(f"{profile}: {len(warnings)} warning(s)")
            if not args.no_render:
                write_generated(profile)

    return 1 if failed else 0
