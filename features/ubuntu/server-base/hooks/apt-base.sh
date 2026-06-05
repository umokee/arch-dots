#!/usr/bin/env bash
set -euo pipefail

SUDO=(sudo)
if [[ "${EUID}" -eq 0 ]]; then
  SUDO=()
fi

export DEBIAN_FRONTEND=noninteractive

"${SUDO[@]}" apt-get update

"${SUDO[@]}" apt-get install -y \
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
  tcpdump

"${SUDO[@]}" systemctl enable --now systemd-timesyncd.service || true
"${SUDO[@]}" systemctl enable --now ssh.service || true
"${SUDO[@]}" systemctl enable --now fail2ban.service || true

"${SUDO[@]}" sysctl --system || true
"${SUDO[@]}" systemctl restart systemd-journald.service || true
