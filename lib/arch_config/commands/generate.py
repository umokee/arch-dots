from __future__ import annotations

from pathlib import Path

from arch_config.commands.common import profile_from_args
from arch_config.engine import (
    render_automount_unit,
    render_file,
    render_mount_unit,
    resolve,
    write_generated,
)
from arch_config.paths import GENERATED_DIR
from arch_config.ui import print_error, print_header, print_key_values, print_success


def cmd_generate(args) -> int:
    state = write_generated(profile_from_args(args))
    print_header("archctl generate", str(GENERATED_DIR))
    print_key_values(
        "Generated artifacts",
        [
            ("pacman", len(state.pacman)),
            ("aur", len(state.aur)),
            ("files", len(state.files)),
            ("mounts", len(state.mounts)),
        ],
    )
    return 0


def cmd_check_generated(args) -> int:
    try:
        write_generated(profile_from_args(args))
    except Exception as exc:
        print_error(str(exc))
        return 1

    print_success("generated artifacts render correctly")
    return 0


def cmd_generated(args) -> int:
    state = resolve(profile_from_args(args))

    if args.generated_cmd == "list":
        for item in state.files:
            print(f"{item.mode}:{item.target} <- {item.feature}/{item.source}")
        for item in state.links:
            print(f"link:{item.target} <- {item.source}")
        for mount in state.mounts:
            print(f"system:{mount.mount_unit} -> /etc/systemd/system/{mount.mount_unit}")
            if mount.automount:
                print(f"system:{mount.automount_unit} -> /etc/systemd/system/{mount.automount_unit}")
        return 0

    if args.generated_cmd == "show":
        name = args.name
        for item in state.files:
            if name in {item.target, item.name, Path(item.target).name}:
                if item.mode == "link":
                    print(f"symlink: {item.target_abs} -> {item.source_abs}")
                else:
                    print(render_file(item, state.config), end="")
                return 0

        for mount in state.mounts:
            if name in {mount.mount_unit, Path(mount.mount_unit).name}:
                print(render_mount_unit(mount), end="")
                return 0
            if name in {mount.automount_unit, Path(mount.automount_unit).name}:
                print(render_automount_unit(mount), end="")
                return 0

        print(f"not found: {name}")
        return 1

    return 0
