from __future__ import annotations

import json
import os
import shutil
import subprocess
import tempfile
from pathlib import Path
from typing import Any

from arch_config.model import FileItem, MountItem, ResolvedState
from arch_config.paths import GENERATED_DIR, HOOKS_DIR, ROOT
from arch_config.render.template import render_template_text
from arch_config.resolver import resolve
from arch_config.system.shell import run, run_root


def render_file(item: FileItem, config: dict[str, Any]) -> str:
    if item.mode == "template":
        return render_template_text(item.source_abs.read_text(encoding="utf-8"), config)
    if item.type == "dir":
        return f"# directory link/copy: {item.source_abs}\n"
    return item.source_abs.read_text(encoding="utf-8")


def render_mount_unit(mount: MountItem) -> str:
    opts = ",".join(mount.options)
    return f"""# Managed by archctl
[Unit]
Description=Mount {mount.what} at {mount.where}

[Mount]
What={mount.what}
Where={mount.where}
Type={mount.type}
Options={opts}
DirectoryMode={mount.directory_mode}

[Install]
WantedBy={mount.wanted_by}
"""


def render_automount_unit(mount: MountItem) -> str:
    return f"""# Managed by archctl
[Unit]
Description=Automount {mount.where}

[Automount]
Where={mount.where}
TimeoutIdleSec={mount.timeout_idle_sec}

[Install]
WantedBy={mount.wanted_by}
"""


def manifest(state: ResolvedState) -> dict[str, Any]:
    return {
        "profile": state.profile,
        "features": state.features,
        "pacman": state.pacman,
        "aur": state.aur,
        "dirs": [{"target": item.target, "target_abs": str(item.target_abs), "permissions": item.permissions} for item in state.dirs],
        "files": [{"feature": item.feature, "source": item.source, "target": item.target, "mode": item.mode, "type": item.type} for item in state.files],
        "links": [{"source": item.source, "target": item.target} for item in state.links],
        "systemd": [item.__dict__ for item in state.systemd],
        "hooks": [item.__dict__ for item in state.hooks],
        "mounts": [{"name": item.name, "what": item.what, "where": item.where, "unit": item.enabled_unit} for item in state.mounts],
    }


def validate(profile: str) -> tuple[int, list[str], list[str]]:
    errors: list[str] = []
    warnings: list[str] = []
    try:
        state = resolve(profile)
    except Exception as exc:
        return 1, [str(exc)], []
    seen_targets: dict[str, str] = {}
    for item in state.files:
        if not item.source_abs.exists():
            errors.append(f"missing source for {item.feature}: {item.source_abs}")
        old = seen_targets.get(item.target)
        if old:
            warnings.append(f"duplicate target {item.target}: {old} and {item.feature}")
        seen_targets[item.target] = item.feature
        if item.mode not in {"link", "copy", "template"}:
            errors.append(f"bad file mode for {item.target}: {item.mode}")
    for item in state.hooks:
        if not (HOOKS_DIR / item.script).exists():
            errors.append(f"missing hook script: {HOOKS_DIR / item.script}")
    return (1 if errors else 0), errors, warnings


def write_generated(profile: str) -> ResolvedState:
    state = resolve(profile)
    if GENERATED_DIR.exists():
        shutil.rmtree(GENERATED_DIR)
    (GENERATED_DIR / "packages").mkdir(parents=True)
    (GENERATED_DIR / "files").mkdir(parents=True)
    (GENERATED_DIR / "systemd").mkdir(parents=True)
    (GENERATED_DIR / "hooks").mkdir(parents=True)
    (GENERATED_DIR / "packages/pacman.txt").write_text("\n".join(state.pacman) + "\n", encoding="utf-8")
    (GENERATED_DIR / "packages/aur.txt").write_text("\n".join(state.aur) + "\n", encoding="utf-8")
    for item in state.files:
        if item.mode in {"copy", "template"}:
            safe = item.target.strip("~/").replace("/", "__") or item.name
            (GENERATED_DIR / "files" / safe).write_text(render_file(item, state.config), encoding="utf-8")
    for mount in state.mounts:
        (GENERATED_DIR / "files" / mount.mount_unit).write_text(render_mount_unit(mount), encoding="utf-8")
        if mount.automount:
            (GENERATED_DIR / "files" / mount.automount_unit).write_text(render_automount_unit(mount), encoding="utf-8")
    (GENERATED_DIR / "links.txt").write_text("\n".join(f"{i.target} -> {i.source}" for i in state.links) + ("\n" if state.links else ""), encoding="utf-8")
    (GENERATED_DIR / "systemd/system.txt").write_text("\n".join(i.unit for i in state.systemd if i.scope == "system") + "\n", encoding="utf-8")
    (GENERATED_DIR / "systemd/user.txt").write_text("\n".join(i.unit for i in state.systemd if i.scope == "user") + "\n", encoding="utf-8")
    (GENERATED_DIR / "hooks/post.txt").write_text("\n".join(i.script for i in state.hooks if i.run == "post") + "\n", encoding="utf-8")
    (GENERATED_DIR / "manifest.json").write_text(json.dumps(manifest(state), indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    return state


def installed_packages() -> set[str]:
    try:
        out = subprocess.check_output(["pacman", "-Qq"], text=True, stderr=subprocess.DEVNULL)
        return set(out.splitlines())
    except Exception:
        return set()


def foreign_packages() -> set[str]:
    try:
        out = subprocess.check_output(["pacman", "-Qmq"], text=True, stderr=subprocess.DEVNULL)
        return set(out.splitlines())
    except Exception:
        return set()


def explicit_native_packages() -> set[str]:
    try:
        out = subprocess.check_output(["pacman", "-Qqen"], text=True, stderr=subprocess.DEVNULL)
        return set(out.splitlines())
    except Exception:
        return set()


def orphan_packages() -> set[str]:
    try:
        out = subprocess.check_output(["pacman", "-Qqdt"], text=True, stderr=subprocess.DEVNULL)
        return set(out.splitlines())
    except Exception:
        return set()


def _protected_by_pattern(pkg: str, patterns: list[str]) -> bool:
    import fnmatch
    return any(fnmatch.fnmatch(pkg, pat) for pat in patterns)


def prune_plan(profile: str, *, include_aur: bool = True, include_orphans: bool = False) -> dict[str, list[str]]:
    state = resolve(profile)
    ignore = state.config.get("ignore", {}) if isinstance(state.config.get("ignore", {}), dict) else {}
    prune_cfg = state.config.get("prune", {}) if isinstance(state.config.get("prune", {}), dict) else {}

    ignored_native = set(str(x) for x in ignore.get("pacman", []))
    ignored_foreign = set(str(x) for x in ignore.get("foreign", []))
    protected = set(str(x) for x in prune_cfg.get("protected", []))
    patterns = [str(x) for x in prune_cfg.get("protect_patterns", [])]

    wanted_native = set(state.pacman) | ignored_native | protected
    wanted_foreign = set(state.aur) | ignored_foreign | protected

    native_remove = sorted(
        p for p in explicit_native_packages()
        if p not in wanted_native and not _protected_by_pattern(p, patterns)
    )
    foreign_remove = sorted(
        p for p in foreign_packages()
        if include_aur and p not in wanted_foreign and not _protected_by_pattern(p, patterns)
    )
    orphans_remove = sorted(orphan_packages()) if include_orphans else []
    return {"pacman": native_remove, "aur": foreign_remove, "orphans": orphans_remove}


def print_prune_plan(profile: str, *, include_aur: bool = True, include_orphans: bool = False) -> dict[str, list[str]]:
    plan = prune_plan(profile, include_aur=include_aur, include_orphans=include_orphans)
    print(f"Prune profile: {profile}")
    print(f"Native explicit packages to remove: {len(plan['pacman'])}")
    print(f"Foreign/AUR packages to remove: {len(plan['aur'])}")
    print(f"Orphan packages to remove: {len(plan['orphans'])}")
    for title, key in [("Native", "pacman"), ("Foreign/AUR", "aur"), ("Orphans", "orphans")]:
        if plan[key]:
            print(f"\n{title}:")
            for pkg in plan[key]:
                print(f"  - {pkg}")
    return plan


def apply_prune_plan(profile: str, *, include_aur: bool = True, include_orphans: bool = False, dry_run: bool = False, yes: bool = False) -> int:
    plan = print_prune_plan(profile, include_aur=include_aur, include_orphans=include_orphans)
    remove = [*plan["pacman"], *plan["aur"], *plan["orphans"]]
    if not remove:
        print("Nothing to prune.")
        return 0
    if not yes and not dry_run:
        answer = input("Remove these packages? [y/N] ").strip().lower()
        if answer not in {"y", "yes"}:
            print("cancelled")
            return 1
    run_root(["pacman", "-Rns", "--", *remove], dry_run=dry_run, cwd=ROOT)
    return 0


def print_plan(profile: str) -> ResolvedState:
    state = resolve(profile)
    installed = installed_packages()
    missing = [p for p in state.pacman if p not in installed]
    missing_aur = [p for p in state.aur if p not in installed]
    print(f"Profile: {profile}")
    print(f"Features: {len(state.features)}")
    print(f"Pacman packages: {len(state.pacman)} wanted, {len(missing)} missing")
    print(f"AUR packages: {len(state.aur)} wanted, {len(missing_aur)} missing")
    print(f"Files: {len(state.files)}")
    print(f"Dirs: {len(state.dirs)}")
    print(f"Links: {len(state.links)}")
    print(f"Systemd units: {len(state.systemd)}")
    print(f"Mounts: {len(state.mounts)}")
    print(f"Hooks: {len(state.hooks)}")
    if missing:
        print("\nMissing pacman:")
        for p in missing: print(f"  + {p}")
    if missing_aur:
        print("\nMissing AUR:")
        for p in missing_aur: print(f"  + {p}")
    print("\nFiles:")
    for item in state.files:
        print(f"  {item.mode:8} {item.feature}: {item.source} -> {item.target}")
    if state.mounts:
        print("\nMounts:")
        for m in state.mounts:
            print(f"  {m.what} -> {m.where} [{m.enabled_unit}]")
    return state


def _write_home_or_system(target: Path, content: str, permissions: str, owner: str, group: str, *, dry_run: bool) -> None:
    is_system = target.is_absolute() and not str(target).startswith(str(Path.home()))
    if is_system:
        with tempfile.TemporaryDirectory(prefix="archctl-file-") as d:
            tmp = Path(d) / target.name
            tmp.write_text(content, encoding="utf-8")
            run_root(["install", "-D", "-m", permissions, "-o", owner, "-g", group, str(tmp), str(target)], dry_run=dry_run)
    else:
        print(f"write {target}")
        if dry_run: return
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(content, encoding="utf-8")
        os.chmod(target, int(permissions, 8))


def _replace_with_symlink(target: Path, source: Path, *, dry_run: bool) -> None:
    print(f"link {target} -> {source}")
    if dry_run:
        return
    target.parent.mkdir(parents=True, exist_ok=True)
    if target.is_symlink() or target.exists():
        if target.is_dir() and not target.is_symlink():
            backup = target.with_name(target.name + ".backup-archctl")
            if backup.exists():
                shutil.rmtree(backup)
            target.rename(backup)
        else:
            target.unlink()
    target.symlink_to(source, target_is_directory=source.is_dir())


def _ensure_dir(target: Path, permissions: str, *, dry_run: bool) -> None:
    print(f"mkdir {target}")
    if dry_run:
        return

    # Previous archctl versions could manage a whole directory as a symlink,
    # for example ~/.config/quickshell -> old repo/dots/....
    # pathlib.mkdir(..., exist_ok=True) raises FileExistsError in that case.
    # Here the desired state is a real directory, so remove only the symlink,
    # not the directory it points to.
    if target.is_symlink():
        target.unlink()

    if target.exists():
        if not target.is_dir():
            target.unlink()
            target.mkdir(parents=True, exist_ok=True)
        os.chmod(target, int(permissions, 8))
        return

    target.mkdir(parents=True, exist_ok=True)
    os.chmod(target, int(permissions, 8))


def _ensure_system_dir(target: Path, permissions: str, *, dry_run: bool) -> None:
    # install -d fails when the target exists as a symlink. Handle that
    # explicitly through sudo/root, then create the directory normally.
    run_root([
        "sh",
        "-c",
        'target="$1"; mode="$2"; '
        'if [ -L "$target" ]; then rm -f -- "$target"; fi; '
        'if [ -e "$target" ] && [ ! -d "$target" ]; then rm -f -- "$target"; fi; '
        'install -d -m "$mode" -- "$target"',
        "archctl-ensure-dir",
        str(target),
        permissions,
    ], dry_run=dry_run)


def _apply_file(item: FileItem, config: dict[str, Any], *, dry_run: bool) -> None:
    if item.mode == "link":
        _replace_with_symlink(item.target_abs, item.source_abs, dry_run=dry_run)
        return
    content = render_file(item, config)
    perms = "755" if item.executable else item.permissions
    _write_home_or_system(item.target_abs, content, perms, item.owner, item.group, dry_run=dry_run)


def switch(profile: str, *, with_aur: bool = False, helper: str = "yay", dry_run: bool = False, yes: bool = False, strict: bool = False, prune_aur: bool = True, include_orphans: bool = False) -> int:
    code, errors, warnings = validate(profile)
    for w in warnings: print("warning:", w)
    if errors:
        for e in errors: print("error:", e)
        return 1
    state = print_plan(profile)
    if not yes and not dry_run:
        answer = input("Apply this plan? [y/N] ").strip().lower()
        if answer not in {"y", "yes"}:
            print("cancelled")
            return 1
    installed = installed_packages()
    missing = [p for p in state.pacman if p not in installed]
    if missing:
        run_root(["pacman", "-S", "--needed", *missing], dry_run=dry_run, cwd=ROOT)
    if with_aur:
        for pkg in [p for p in state.aur if p not in installed]:
            run([helper, "-S", "--needed", "--noconfirm", pkg], dry_run=dry_run, cwd=ROOT)
    elif state.aur:
        print("AUR skipped. Use --aur to install AUR packages.")
    for d in state.dirs:
        if d.target_abs.is_absolute() and not str(d.target_abs).startswith(str(Path.home())):
            _ensure_system_dir(d.target_abs, d.permissions, dry_run=dry_run)
        else:
            _ensure_dir(d.target_abs, d.permissions, dry_run=dry_run)
    for item in state.files:
        _apply_file(item, state.config, dry_run=dry_run)
    for item in state.links:
        _replace_with_symlink(item.target_abs, item.source_abs, dry_run=dry_run)
    for mount in state.mounts:
        _write_home_or_system(Path('/etc/systemd/system') / mount.mount_unit, render_mount_unit(mount), '644', 'root', 'root', dry_run=dry_run)
        if mount.automount:
            _write_home_or_system(Path('/etc/systemd/system') / mount.automount_unit, render_automount_unit(mount), '644', 'root', 'root', dry_run=dry_run)
    if any(i.scope == 'system' for i in state.systemd):
        run_root(["systemctl", "daemon-reload"], dry_run=dry_run)
    if any(i.scope == 'user' for i in state.systemd):
        run(["systemctl", "--user", "daemon-reload"], dry_run=dry_run)
    for item in state.systemd:
        base = ["systemctl"] if item.scope == "system" else ["systemctl", "--user"]
        cmd = [*base, "enable"]
        if item.start:
            cmd.append("--now")
        cmd.append(item.unit)
        if item.scope == "system": run_root(cmd, dry_run=dry_run)
        else: run(cmd, dry_run=dry_run)
    for hook in state.hooks:
        script = HOOKS_DIR / hook.script
        run(["bash", str(script)], dry_run=dry_run, cwd=ROOT)
    if strict:
        return apply_prune_plan(profile, include_aur=(with_aur and prune_aur), include_orphans=include_orphans, dry_run=dry_run, yes=yes)
    return 0
