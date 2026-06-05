#!/usr/bin/env bash
set -euo pipefail

SUDO=(sudo)
if [[ "${EUID}" -eq 0 ]]; then
  SUDO=()
fi

export DEBIAN_FRONTEND=noninteractive

wait_apt_locks() {
  local locks=(
    /var/lib/dpkg/lock-frontend
    /var/lib/dpkg/lock
    /var/cache/apt/archives/lock
    /var/lib/apt/lists/lock
  )

  local lock
  local waited=0

  while true; do
    local busy=0

    for lock in "${locks[@]}"; do
      if command -v fuser >/dev/null 2>&1; then
        if fuser "$lock" >/dev/null 2>&1; then
          busy=1
          echo "apt/dpkg lock is busy: $lock"
        fi
      else
        if lsof "$lock" >/dev/null 2>&1; then
          busy=1
          echo "apt/dpkg lock is busy: $lock"
        fi
      fi
    done

    if [[ "$busy" -eq 0 ]]; then
      break
    fi

    waited=$((waited + 10))

    if [[ "$waited" -gt 1800 ]]; then
      echo "Timed out waiting for apt/dpkg locks"
      exit 1
    fi

    echo "waiting for another package process to finish..."
    sleep 10
  done

  "${SUDO[@]}" dpkg --configure -a || true
}

apt_update() {
  wait_apt_locks
  "${SUDO[@]}" apt-get -o DPkg::Lock::Timeout=900 update
}

apt_install() {
  wait_apt_locks
  "${SUDO[@]}" apt-get -o DPkg::Lock::Timeout=900 install -y "$@"
}

apt_update

apt_install \
  ca-certificates \
  curl \
  wget \
  unzip \
  jq \
  openssl \
  gnupg \
  lsb-release \
  apt-transport-https \
  software-properties-common \
  systemd \
  systemd-timesyncd \
  openssh-server \
  ufw \
  fail2ban \
  unattended-upgrades \
  logrotate \
  htop \
  btop \
  tmux \
  vim \
  nano \
  git \
  rsync \
  socat \
  iproute2 \
  iputils-ping \
  dnsutils \
  traceroute \
  tcpdump \
  lsof \
  psmisc \
  sqlite3 \
  python3 \
  python-is-python3

"${SUDO[@]}" systemctl enable --now systemd-timesyncd.service || true
"${SUDO[@]}" systemctl enable --now ssh.service || true
"${SUDO[@]}" systemctl enable --now fail2ban.service || true

"${SUDO[@]}" sysctl --system || true
"${SUDO[@]}" systemctl restart systemd-journald.service || true
