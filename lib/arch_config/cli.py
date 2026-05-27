from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

from arch_config import __version__
from arch_config.engine import (
    apply_prune_plan,
    manifest,
    print_plan,
    print_prune_plan,
    resolve,
    switch,
    validate,
    write_generated,
    render_file,
    render_mount_unit,
    render_automount_unit,
)
from arch_config.paths import GENERATED_DIR, PROFILES_DIR


def _profile(args) -> str:
    return args.profile or "desktop"


def cmd_validate(args) -> int:
    code, errors, warnings = validate(_profile(args))
    if args.json:
        print(json.dumps({"errors": errors, "warnings": warnings}, ensure_ascii=False, indent=2))
        return code
    print(f"Profile: {_profile(args)}")
    for w in warnings: print(f"[WARN] {w}")
    for e in errors: print(f"[ERR ] {e}")
    if not errors: print("[OK] config schema looks good")
    return code


def cmd_plan(args) -> int:
    print_plan(_profile(args))
    return 0


def cmd_generate(args) -> int:
    state = write_generated(_profile(args))
    print("Generated:")
    print(f"  {GENERATED_DIR}/")
    print(f"pacman: {len(state.pacman)}")
    print(f"aur: {len(state.aur)}")
    print(f"files: {len(state.files)}")
    print(f"mounts: {len(state.mounts)}")
    return 0


def cmd_check_generated(args) -> int:
    try:
        write_generated(_profile(args))
    except Exception as exc:
        print(f"[ERR] {exc}")
        return 1
    print("[OK] generated artifacts render correctly")
    return 0


def cmd_generated(args) -> int:
    state = resolve(_profile(args))
    if args.generated_cmd == "list":
        for item in state.files:
            print(f"{item.mode}:{item.target} <- {item.feature}/{item.source}")
        for item in state.links:
            print(f"link:{item.target} <- {item.source}")
        for m in state.mounts:
            print(f"system:{m.mount_unit} -> /etc/systemd/system/{m.mount_unit}")
            if m.automount:
                print(f"system:{m.automount_unit} -> /etc/systemd/system/{m.automount_unit}")
        return 0
    if args.generated_cmd == "show":
        name = args.name
        for item in state.files:
            if name in {item.target, item.name, Path(item.target).name}:
                if item.mode == 'link':
                    print(f"symlink: {item.target_abs} -> {item.source_abs}")
                else:
                    print(render_file(item, state.config), end="")
                return 0
        for m in state.mounts:
            if name in {m.mount_unit, Path(m.mount_unit).name}:
                print(render_mount_unit(m), end=""); return 0
            if name in {m.automount_unit, Path(m.automount_unit).name}:
                print(render_automount_unit(m), end=""); return 0
        print(f"not found: {name}")
        return 1
    return 0


def cmd_vars(args) -> int:
    state = resolve(_profile(args))
    keys = [k for k in state.config.keys() if not k.startswith('_')]
    print(json.dumps({k: state.config[k] for k in keys}, ensure_ascii=False, indent=2))
    return 0


def cmd_self_test(args) -> int:
    profiles = [p.stem for p in PROFILES_DIR.glob('*.toml')] if args.all_profiles else [_profile(args)]
    failed = 0
    for profile in profiles:
        code, errors, warnings = validate(profile)
        if code:
            failed += 1
            print(f"[ERR] {profile}")
            for e in errors: print(f"  - {e}")
        else:
            print(f"[OK] {profile}: {len(warnings)} warning(s)")
            if not args.no_render:
                write_generated(profile)
    return 1 if failed else 0


def cmd_switch(args) -> int:
    return switch(
        _profile(args),
        with_aur=args.aur,
        helper=args.helper,
        dry_run=args.dry_run,
        yes=args.yes,
        strict=args.strict,
        prune_aur=not args.no_prune_aur,
        include_orphans=args.remove_orphans,
    )


def cmd_prune(args) -> int:
    if args.apply:
        return apply_prune_plan(
            _profile(args),
            include_aur=not args.no_aur,
            include_orphans=args.remove_orphans,
            dry_run=args.dry_run,
            yes=args.yes,
        )
    print_prune_plan(_profile(args), include_aur=not args.no_aur, include_orphans=args.remove_orphans)
    return 0


def main(argv: list[str] | None = None) -> int:
    if argv is None:
        argv = sys.argv[1:]

    # Compatibility with the old habit: `archctl -p desktop --aur`.
    # If switch-only flags are passed without a subcommand, default to `switch`.
    switch_flags = {"--aur", "--helper", "--dry-run", "-y", "--yes", "--strict", "--no-prune-aur", "--remove-orphans"}
    known_commands = {"validate", "plan", "diff", "status", "generate", "check-generated", "vars", "switch", "self-test", "generated", "prune", "clean"}
    has_command = any(arg in known_commands for arg in argv)
    has_switch_flag = any(arg in switch_flags for arg in argv)
    if has_switch_flag and not has_command:
        # Keep global flags before the inserted subcommand.
        insert_at = 0
        while insert_at < len(argv):
            arg = argv[insert_at]
            if arg in {"-p", "--profile"} and insert_at + 1 < len(argv):
                insert_at += 2
                continue
            if arg == "--version":
                insert_at += 1
                continue
            break
        argv = [*argv[:insert_at], "switch", *argv[insert_at:]]

    parser = argparse.ArgumentParser(prog="archctl")
    parser.add_argument('-p', '--profile', default=None)
    parser.add_argument('--version', action='store_true')
    sub = parser.add_subparsers(dest='command')

    p = sub.add_parser('validate'); p.add_argument('--json', action='store_true'); p.set_defaults(func=cmd_validate)
    for name in ['plan', 'diff', 'status']:
        p = sub.add_parser(name); p.set_defaults(func=cmd_plan)
    p = sub.add_parser('generate'); p.set_defaults(func=cmd_generate)
    p = sub.add_parser('check-generated'); p.set_defaults(func=cmd_check_generated)
    p = sub.add_parser('vars'); p.set_defaults(func=cmd_vars)
    p = sub.add_parser('switch'); p.add_argument('--aur', action='store_true'); p.add_argument('--helper', default='yay'); p.add_argument('--dry-run', action='store_true'); p.add_argument('-y','--yes', action='store_true'); p.add_argument('--strict', action='store_true'); p.add_argument('--no-prune-aur', action='store_true'); p.add_argument('--remove-orphans', action='store_true'); p.set_defaults(func=cmd_switch)
    p = sub.add_parser('prune'); p.add_argument('--apply', action='store_true'); p.add_argument('--dry-run', action='store_true'); p.add_argument('-y','--yes', action='store_true'); p.add_argument('--no-aur', action='store_true'); p.add_argument('--remove-orphans', action='store_true'); p.set_defaults(func=cmd_prune)
    p = sub.add_parser('clean'); p.add_argument('--apply', action='store_true'); p.add_argument('--dry-run', action='store_true'); p.add_argument('-y','--yes', action='store_true'); p.add_argument('--no-aur', action='store_true'); p.add_argument('--remove-orphans', action='store_true'); p.set_defaults(func=cmd_prune)

    p = sub.add_parser('self-test'); p.add_argument('--all-profiles', action='store_true'); p.add_argument('--no-render', action='store_true'); p.set_defaults(func=cmd_self_test)

    p = sub.add_parser('generated')
    gsub = p.add_subparsers(dest='generated_cmd', required=True)
    gl = gsub.add_parser('list'); gl.set_defaults(func=cmd_generated)
    gs = gsub.add_parser('show'); gs.add_argument('name'); gs.set_defaults(func=cmd_generated)

    args = parser.parse_args(argv)
    if args.version:
        print(f"archctl {__version__}")
        return 0
    if not hasattr(args, 'func'):
        parser.print_help()
        return 1
    return args.func(args)


if __name__ == '__main__':
    raise SystemExit(main())
