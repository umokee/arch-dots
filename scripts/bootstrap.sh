#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROFILE="${ARCH_PROFILE:-desktop}"
SKIP_INSTALL="${ARCHCTL_SKIP_INSTALL:-0}"
BOOTSTRAP_CACHYOS="${ARCHCTL_BOOTSTRAP_CACHYOS:-auto}"
BUILD_USER="${ARCHCTL_BUILD_USER:-}"

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

ensure_arch_like() {
  if ! has pacman; then
    die "pacman was not found. This bootstrap is only for Arch/CachyOS-like systems."
  fi
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

  die "cannot detect non-root build user. Run bootstrap as your normal user or set ARCHCTL_BUILD_USER=<username>"
}

ensure_build_user() {
  if [ -z "$BUILD_USER" ]; then
    BUILD_USER="$(detect_build_user)"
  fi

  if ! id "$BUILD_USER" > /dev/null 2>&1; then
    die "build user does not exist: $BUILD_USER"
  fi
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

run_as_build_user() {
  local dir="$1"
  shift

  if [ "$(id -u)" -ne 0 ]; then
    (
      cd "$dir"
      "$@"
    )
    return
  fi

  ensure_build_user

  local quoted_cmd
  local quoted_dir

  printf -v quoted_cmd "%q " "$@"
  printf -v quoted_dir "%q" "$dir"

  su - "$BUILD_USER" -c "cd $quoted_dir && $quoted_cmd"
}

prepare_build_dir() {
  local dir="$1"

  if [ "$(id -u)" -eq 0 ]; then
    ensure_build_user
    chown -R "$BUILD_USER:$(id -gn "$BUILD_USER")" "$dir"
  fi
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

install_bootstrap_pacman_packages() {
  log "Installing bootstrap pacman packages"

  run_as_root pacman -Syu --needed --noconfirm \
    git \
    base-devel \
    go \
    python \
    rsync \
    unzip \
    sudo \
    pacman-contrib \
    curl \
    wget
}

install_yay_if_needed() {
  if has yay; then
    echo "yay already installed"
    return
  fi

  log "Installing yay from AUR"

  local tmp
  tmp="$(mktemp -d /tmp/archctl-yay.XXXXXX)"
  prepare_build_dir "$tmp"

  run_as_build_user "$tmp" \
    git clone https://aur.archlinux.org/yay.git

  if run_as_build_user "$tmp/yay" \
    makepkg -si --needed --noconfirm; then
    echo "yay installed"
    return
  fi

  warn "makepkg -si failed. Trying fallback: makepkg + root pacman -U"

  run_as_build_user "$tmp/yay" \
    makepkg --needed --noconfirm

  local pkgfile
  pkgfile="$(find "$tmp/yay" -maxdepth 1 -type f -name '*.pkg.tar*' ! -name '*-debug-*' | head -n 1)"

  if [ -z "$pkgfile" ]; then
    die "yay package archive was not found after makepkg"
  fi

  run_as_root pacman -U --needed --noconfirm "$pkgfile"

  if ! has yay; then
    die "yay installation finished, but yay is still not in PATH"
  fi

  echo "yay installed"
}

install_aur_package_with_yay() {
  local package="$1"

  if ! has yay; then
    die "yay is required before installing AUR package: $package"
  fi

  log "Installing AUR package with yay: $package"

  if run_as_build_user "$ROOT" \
    yay -S --needed --noconfirm "$package"; then
    return
  fi

  die "yay failed to install AUR package: $package"
}

install_launcher() {
  if [ "$SKIP_INSTALL" = "1" ]; then
    echo "launcher installation skipped"
    return
  fi

  log "Installing archctl launcher"
  "$ROOT/scripts/archctl" install --force
}

run_checks() {
  log "Checking repository"
  "$ROOT/scripts/archctl" -p "$PROFILE" doctor || true

  log "Validating profile: $PROFILE"
  "$ROOT/scripts/archctl" -p "$PROFILE" validate
}

main() {
  ensure_arch_like
  ensure_build_user

  install_cachyos_repos_if_enabled

  install_bootstrap_pacman_packages

  install_yay_if_needed

  install_launcher

  run_checks

  log "Done"

  echo "Profile: $PROFILE"
  echo
  echo "Next commands:"
  echo "  ./scripts/archctl -p $PROFILE diff"
  echo "  ./scripts/archctl -p $PROFILE switch --strict --aur --no-prune-aur"
}

main "$@"
