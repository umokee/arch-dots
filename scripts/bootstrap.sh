#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

PROFILE="${ARCH_PROFILE:-desktop}"
BUILD_USER="${ARCHCTL_BUILD_USER:-}"
AUR=1
STRICT=0
REMOVE_ORPHANS=0
YES=0
RUN_SWITCH=0
RUN_CHECKS=1
INSTALL_COMPLETIONS=0
BOOTSTRAP_CACHYOS="${ARCHCTL_BOOTSTRAP_CACHYOS:-auto}"

log() {
  printf '\n== %s ==\n' "$*"
}

warn() {
  echo "WARNING: $*" >&2
}

die() {
  echo "ERROR: $*" >&2
  exit 1
}

has() {
  command -v "$1" > /dev/null 2>&1
}

usage() {
  cat << USAGE
Usage:
  ./scripts/bootstrap.sh [options]

Options:
  -p, --profile NAME        Profile to use. Default: ${PROFILE}
  --user NAME               Non-root build/user account. Default: auto-detect

  --cachyos                 Force CachyOS repo bootstrap
  --no-cachyos              Disable CachyOS repo bootstrap
  --cachyos-auto            Use config/common.toml [cachyos].bootstrap_repos. Default

  --aur                     Install/use AUR helper. Default
  --no-aur                  Do not install/use AUR helper

  --check                   Run validate/self-test/generate checks. Default
  --no-check                Skip checks

  --install-completions     Install shell completions for current shell

  --switch                  After bootstrap, run archctl switch
  --strict                  With --switch, enable strict package cleanup
  --remove-orphans          With --strict, also remove orphan packages
  -y, --yes                 Non-interactive yes for archctl switch/prune

  -h, --help                Show this help

Recommended first run:
  ./scripts/bootstrap.sh -p desktop

Then inspect:
  ./scripts/archctl -p desktop diff --strict --aur

Then apply:
  ./scripts/archctl -p desktop switch --aur --strict
USAGE
}

while [ "$#" -gt 0 ]; do
  case "$1" in
  -p | --profile)
    PROFILE="${2:-}"
    [ -n "$PROFILE" ] || die "missing value for $1"
    shift 2
    ;;
  --user)
    BUILD_USER="${2:-}"
    [ -n "$BUILD_USER" ] || die "missing value for $1"
    shift 2
    ;;
  --cachyos)
    BOOTSTRAP_CACHYOS=1
    shift
    ;;
  --no-cachyos)
    BOOTSTRAP_CACHYOS=0
    shift
    ;;
  --cachyos-auto)
    BOOTSTRAP_CACHYOS=auto
    shift
    ;;
  --aur)
    AUR=1
    shift
    ;;
  --no-aur)
    AUR=0
    shift
    ;;
  --check)
    RUN_CHECKS=1
    shift
    ;;
  --no-check)
    RUN_CHECKS=0
    shift
    ;;
  --install-completions)
    INSTALL_COMPLETIONS=1
    shift
    ;;
  --switch)
    RUN_SWITCH=1
    shift
    ;;
  --strict)
    STRICT=1
    shift
    ;;
  --remove-orphans)
    REMOVE_ORPHANS=1
    shift
    ;;
  -y | --yes)
    YES=1
    shift
    ;;
  -h | --help)
    usage
    exit 0
    ;;
  *)
    die "unknown option: $1"
    ;;
  esac
done

ensure_arch_like() {
  if ! has pacman; then
    die "pacman was not found. This bootstrap is only for Arch/CachyOS-like systems."
  fi
}

ensure_pacman_keyring() {
  log "Checking pacman keyring"

  run_as_root pacman-key --init || true
  run_as_root pacman-key --populate archlinux || true

  run_as_root pacman -Sy --needed --noconfirm archlinux-keyring ca-certificates
}

detect_build_user() {
  if [ "$(id -u)" -ne 0 ]; then
    id -un
    return
  fi

  if [ -n "${SUDO_USER:-}" ] && [ "$SUDO_USER" != "root" ]; then
    echo "$SUDO_USER"
    return
  fi

  if id user > /dev/null 2>&1; then
    echo "user"
    return
  fi

  die "cannot detect non-root user. Run bootstrap as normal user or pass --user NAME"
}

ensure_build_user() {
  if [ -z "$BUILD_USER" ]; then
    BUILD_USER="$(detect_build_user)"
  fi

  if ! id "$BUILD_USER" > /dev/null 2>&1; then
    die "user does not exist: $BUILD_USER"
  fi
}

user_home() {
  getent passwd "$BUILD_USER" | cut -d: -f6
}

run_as_root() {
  if [ "$(id -u)" -eq 0 ]; then
    "$@"
    return
  fi

  if has sudo && sudo -v > /dev/null 2>&1; then
    sudo "$@"
    return
  fi

  if has su; then
    local quoted_cmd
    local quoted_root

    printf -v quoted_cmd "%q " "$@"
    printf -v quoted_root "%q" "$ROOT"

    su - root -c "cd $quoted_root && $quoted_cmd"
    return
  fi

  die "need root privileges, but neither working sudo nor su was found"
}

run_as_user() {
  local dir="$1"
  shift

  if [ "$(id -u)" -ne 0 ]; then
    (
      cd "$dir"
      "$@"
    )
    return
  fi

  local quoted_cmd
  local quoted_dir

  printf -v quoted_cmd "%q " "$@"
  printf -v quoted_dir "%q" "$dir"

  su - "$BUILD_USER" -c "cd $quoted_dir && $quoted_cmd"
}

read_toml_bool_from_section() {
  local file="$1"
  local section="$2"
  local key="$3"

  [ -f "$file" ] || return 1

  awk -v section="$section" -v key="$key" '
    $0 ~ "^[[:space:]]*\\[" section "\\][[:space:]]*$" {
      in_section = 1
      next
    }

    $0 ~ "^[[:space:]]*\\[" && in_section {
      in_section = 0
    }

    in_section {
      line = $0
      sub(/[[:space:]]*#.*/, "", line)
      pattern = "^[[:space:]]*" key "[[:space:]]*=[[:space:]]*true[[:space:]]*$"

      if (line ~ pattern) {
        found = 1
      }
    }

    END {
      exit found ? 0 : 1
    }
  ' "$file"
}

read_toml_string_from_section() {
  local file="$1"
  local section="$2"
  local key="$3"

  [ -f "$file" ] || return 1

  awk -v section="$section" -v key="$key" '
    $0 ~ "^[[:space:]]*\\[" section "\\][[:space:]]*$" {
      in_section = 1
      next
    }

    $0 ~ "^[[:space:]]*\\[" && in_section {
      in_section = 0
    }

    in_section {
      line = $0
      sub(/[[:space:]]*#.*/, "", line)
      pattern = "^[[:space:]]*" key "[[:space:]]*="

      if (line ~ pattern) {
        sub("^[[:space:]]*" key "[[:space:]]*=[[:space:]]*", "", line)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", line)
        gsub(/^"/, "", line)
        gsub(/"$/, "", line)
        print line
        found = 1
        exit
      }
    }

    END {
      exit found ? 0 : 1
    }
  ' "$file"
}

cachyos_bootstrap_enabled() {
  case "$BOOTSTRAP_CACHYOS" in
  1 | true | yes | on)
    return 0
    ;;
  0 | false | no | off)
    return 1
    ;;
  esac

  read_toml_bool_from_section "$ROOT/config/common.toml" "cachyos" "bootstrap_repos"
}

cachyos_repo_url() {
  read_toml_string_from_section "$ROOT/config/common.toml" "cachyos" "repo_installer_url" ||
    echo "https://mirror.cachyos.org/cachyos-repo.tar.xz"
}

install_minimal_pacman_tools() {
  log "Installing minimal bootstrap tools"

  run_as_root pacman -Sy --needed --noconfirm \
    archlinux-keyring \
    ca-certificates \
    curl \
    git \
    sudo \
    python \
    base-devel
}

install_cachyos_repos_if_enabled() {
  if ! cachyos_bootstrap_enabled; then
    echo "CachyOS repository bootstrap is disabled."
    return
  fi

  if [ ! -f "$ROOT/scripts/bootstrap-cachyos-repos.sh" ]; then
    die "CachyOS bootstrap is enabled, but scripts/bootstrap-cachyos-repos.sh is missing"
  fi

  local url
  url="$(cachyos_repo_url)"

  log "Installing CachyOS repositories"

  run_as_root env \
    CACHYOS_REPO_URL="$url" \
    bash "$ROOT/scripts/bootstrap-cachyos-repos.sh"
}

install_bootstrap_packages() {
  log "Installing bootstrap packages"

  run_as_root pacman -Syu --needed --noconfirm \
    git \
    base-devel \
    go \
    python \
    python-pip \
    rsync \
    unzip \
    sudo \
    pacman-contrib \
    curl \
    wget \
    jq \
    fish
}

install_archctl_link() {
  local home
  home="$(user_home)"

  [ -n "$home" ] || die "cannot determine home for $BUILD_USER"

  log "Installing archctl wrapper for $BUILD_USER"

  if [ "$(id -u)" -ne 0 ]; then
    mkdir -p "$HOME/.local/bin"
    ln -sfn "$ROOT/scripts/archctl" "$HOME/.local/bin/archctl"
    chmod +x "$ROOT/scripts/archctl"
    echo "installed: $HOME/.local/bin/archctl -> $ROOT/scripts/archctl"
    return
  fi

  install -d -o "$BUILD_USER" -g "$(id -gn "$BUILD_USER")" "$home/.local/bin"
  ln -sfn "$ROOT/scripts/archctl" "$home/.local/bin/archctl"
  chown -h "$BUILD_USER:$(id -gn "$BUILD_USER")" "$home/.local/bin/archctl"
  chmod +x "$ROOT/scripts/archctl"

  echo "installed: $home/.local/bin/archctl -> $ROOT/scripts/archctl"
}

install_yay_if_needed() {
  if [ "$AUR" != "1" ]; then
    echo "AUR helper bootstrap is disabled."
    return
  fi

  if has yay; then
    echo "yay already installed"
    return
  fi

  log "Installing yay from AUR"

  local tmp
  tmp="$(mktemp -d /tmp/archctl-yay.XXXXXX)"

  if [ "$(id -u)" -eq 0 ]; then
    chown -R "$BUILD_USER:$(id -gn "$BUILD_USER")" "$tmp"
  fi

  run_as_user "$tmp" git clone https://aur.archlinux.org/yay.git

  if run_as_user "$tmp/yay" makepkg -si --needed --noconfirm; then
    echo "yay installed"
    rm -rf "$tmp"
    return
  fi

  warn "makepkg -si failed. Trying fallback: makepkg + root pacman -U"

  run_as_user "$tmp/yay" makepkg --needed --noconfirm

  local pkgfile
  pkgfile="$(find "$tmp/yay" -maxdepth 1 -type f -name '*.pkg.tar*' ! -name '*-debug-*' | head -n 1)"

  if [ -z "$pkgfile" ]; then
    die "yay package archive was not found after makepkg"
  fi

  run_as_root pacman -U --needed --noconfirm "$pkgfile"

  if ! has yay; then
    die "yay installation finished, but yay is still not in PATH"
  fi

  rm -rf "$tmp"
  echo "yay installed"
}

run_checks() {
  if [ "$RUN_CHECKS" != "1" ]; then
    echo "bootstrap checks are disabled."
    return
  fi

  log "Checking archctl"

  "$ROOT/scripts/archctl" --version

  log "Validating profile: $PROFILE"
  "$ROOT/scripts/archctl" -p "$PROFILE" validate

  log "Running self-test"
  "$ROOT/scripts/archctl" -p "$PROFILE" self-test --all-profiles --no-render

  log "Generating files"
  "$ROOT/scripts/archctl" -p "$PROFILE" generate

  log "Checking generated files"
  "$ROOT/scripts/archctl" -p "$PROFILE" check-generated
}

install_completions() {
  if [ "$INSTALL_COMPLETIONS" != "1" ]; then
    return
  fi

  local shell_name="${SHELL##*/}"

  case "$shell_name" in
  fish | bash | zsh)
    log "Installing $shell_name completions"

    if "$ROOT/scripts/archctl" completions "$shell_name" --install --force; then
      echo "completions installed for $shell_name"
    else
      warn "failed to install completions for $shell_name; continuing"
    fi
    ;;
  *)
    warn "unsupported shell for completions: $shell_name"
    ;;
  esac
}

run_switch_if_requested() {
  if [ "$RUN_SWITCH" != "1" ]; then
    return
  fi

  log "Applying profile: $PROFILE"

  local args=("-p" "$PROFILE" "switch")

  if [ "$AUR" = "1" ]; then
    args+=("--aur")
  fi

  if [ "$STRICT" = "1" ]; then
    args+=("--strict")
  fi

  if [ "$REMOVE_ORPHANS" = "1" ]; then
    args+=("--remove-orphans")
  fi

  if [ "$YES" = "1" ]; then
    args+=("--yes")
  fi

  "$ROOT/scripts/archctl" "${args[@]}"
}

main() {
  cd "$ROOT"

  ensure_arch_like
  ensure_build_user

  log "Bootstrap target"
  echo "Root:       $ROOT"
  echo "Profile:    $PROFILE"
  echo "User:       $BUILD_USER"
  echo "AUR:        $AUR"
  echo "CachyOS:    $BOOTSTRAP_CACHYOS"
  echo "Run checks: $RUN_CHECKS"
  echo "Run switch: $RUN_SWITCH"

  ensure_pacman_keyring
  install_minimal_pacman_tools
  install_cachyos_repos_if_enabled
  install_bootstrap_packages
  install_archctl_link
  install_yay_if_needed
  run_checks
  install_completions
  run_switch_if_requested

  log "Done"

  echo "Next safe commands:"
  echo "  ./scripts/archctl -p $PROFILE diff --strict --aur"
  echo "  ./scripts/archctl -p $PROFILE switch --aur --strict"
}

main "$@"
