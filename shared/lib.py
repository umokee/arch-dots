from __future__ import annotations

import os
from collections import OrderedDict

import decman
from decman import Directory, File

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
_DOT_LINKS: OrderedDict[str, tuple[str, str]] = OrderedDict()


def add_packages(*names: str):
    decman.pacman.packages |= {n for n in names if n}


def add_aur(*names: str):
    decman.aur.packages |= {n for n in names if n}


def ignore_packages(*names: str):
    decman.pacman.ignored_packages |= {n for n in names if n}


def system_file(
    path: str,
    content: str,
    mode: int = 0o644,
    owner: str | None = None,
    group: str | None = None,
):
    kwargs = {"content": content, "permissions": mode}
    if owner:
        kwargs["owner"] = owner
    if group:
        kwargs["group"] = group
    decman.files[path] = File(**kwargs)


def repo_file(
    path: str,
    source_rel: str,
    mode: int = 0o644,
    owner: str | None = None,
    group: str | None = None,
):
    kwargs = {"source_file": os.path.join(ROOT, source_rel), "permissions": mode}
    if owner:
        kwargs["owner"] = owner
    if group:
        kwargs["group"] = group
    decman.files[path] = File(**kwargs)


def repo_dir(path: str, source_rel: str, owner: str | None = None):
    kwargs = {"source_directory": os.path.join(ROOT, source_rel)}
    if owner:
        kwargs["owner"] = owner
    decman.directories[path] = Directory(**kwargs)


def enable_units(*units: str):
    decman.systemd.enabled_units |= {u for u in units if u}


def systemd_unit(name: str, content: str, enable: bool = True):
    system_file(f"/etc/systemd/system/{name}", content)
    if enable:
        enable_units(name)


def user_systemd_unit(username: str, name: str, content: str):
    system_file(
        f"/home/{username}/.config/systemd/user/{name}",
        content,
        owner=username,
    )


def tmpfiles(name: str, rules: str):
    system_file(f"/etc/tmpfiles.d/{name}.conf", rules)


def sysctl(name: str, content: str):
    system_file(f"/etc/sysctl.d/{name}.conf", content)


def home_path(username: str, rel: str) -> str:
    return f"/home/{username}/{rel.lstrip('/')}"


def repo_path(source_rel: str) -> str:
    return os.path.join(ROOT, source_rel.lstrip("/"))


def _sh_single_quote(value: str) -> str:
    return "'" + value.replace("'", "'\"'\"'") + "'"


def _render_dotlink_script() -> str:
    lines = [
        "#!/usr/bin/env bash",
        "set -euo pipefail",
        "",
        "backup_existing() {",
        '  local target="$1"',
        '  local backup="$target.backup-$(date +%Y%m%d-%H%M%S)"',
        '  echo "Backing up existing $target -> $backup"',
        '  mv "$target" "$backup"',
        "}",
        "",
        "link_one() {",
        '  local target="$1"',
        '  local source="$2"',
        '  local owner="$3"',
        "",
        '  if [ ! -e "$source" ]; then',
        '    echo "Missing source: $source"',
        "    return 1",
        "  fi",
        "",
        '  install -d -o "$owner" -g "$owner" "$(dirname "$target")"',
        "",
        '  if [ -L "$target" ]; then',
        '    current="$(readlink "$target" || true)"',
        '    if [ "$current" = "$source" ]; then',
        '      chown -h "$owner:$owner" "$target"',
        '      echo "Already linked: $target -> $source"',
        "      return 0",
        "    fi",
        '    rm -f "$target"',
        '  elif [ -e "$target" ]; then',
        '    backup_existing "$target"',
        "  fi",
        "",
        '  ln -sfn "$source" "$target"',
        '  chown -h "$owner:$owner" "$target"',
        '  echo "Linked: $target -> $source"',
        "}",
        "",
    ]

    for target, (source, owner) in _DOT_LINKS.items():
        lines.append(
            "link_one "
            f"{_sh_single_quote(target)} "
            f"{_sh_single_quote(source)} "
            f"{_sh_single_quote(owner)}"
        )

    lines.append("")
    return "\n".join(lines)


def _dotlink_unit() -> str:
    return """
[Unit]
Description=Create symlinks for Decman-managed dotfiles
After=local-fs.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/decman-link-dotfiles
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
"""


def _render_dotlink_files() -> None:
    system_file(
        "/usr/local/bin/decman-link-dotfiles",
        _render_dotlink_script(),
        mode=0o755,
    )
    systemd_unit(
        "decman-link-dotfiles.service",
        _dotlink_unit(),
        enable=True,
    )


def dot_link(username: str, target_rel: str, source_rel: str) -> None:
    """
    Register a symlink:

      /home/<username>/<target_rel> -> <repo>/dots/home/<source_rel>

    Existing non-symlink targets are backed up by the generated script.
    """
    target = home_path(username, target_rel)
    source = repo_path(f"dots/home/{source_rel.lstrip('/')}")
    _DOT_LINKS[target] = (source, username)
    _render_dotlink_files()


def dot_file(
    username: str,
    target_rel: str,
    source_rel: str | None = None,
    mode: int = 0o644,
):
    """
    Symlink one dotfile.

    Example:
      dot_file(user, ".gitconfig")
      ~/.gitconfig -> <repo>/dots/home/.gitconfig

    mode is kept only for compatibility with old calls; the real file mode is
    controlled by the source file in dots/home.
    """
    source = source_rel or target_rel
    dot_link(username, target_rel, source)


def dot_dir(
    username: str,
    target_rel: str,
    source_rel: str | None = None,
):
    """
    Symlink a whole config directory.

    Example:
      dot_dir(user, ".config/hypr", ".config/hyprland")
      ~/.config/hypr -> <repo>/dots/home/.config/hyprland
    """
    source = source_rel or target_rel
    dot_link(username, target_rel, source)


def generated_home_file(
    username: str,
    target_rel: str,
    content: str,
    mode: int = 0o644,
):
    """
    Generate a real file in $HOME.

    Use this only for host-generated files that should not live in dots/home.
    """
    system_file(
        home_path(username, target_rel),
        content,
        mode=mode,
        owner=username,
    )
