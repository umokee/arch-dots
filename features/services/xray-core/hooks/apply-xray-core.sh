#!/usr/bin/env bash
set -euo pipefail

if [[ ${EUID} -ne 0 ]]; then
  exec sudo -E bash "$0" "$@"
fi

export DEBIAN_FRONTEND=noninteractive

env_file="/etc/archctl/xray-core.env"
config_file="/usr/local/etc/xray/config.json"
links_file="/root/xray-client-links.txt"

if [[ ! -f ${env_file} ]]; then
  echo "Missing ${env_file}"
  exit 1
fi

# shellcheck disable=SC1090
source "${env_file}"

XRAY_PUBLIC_HOST="${XRAY_PUBLIC_HOST:?XRAY_PUBLIC_HOST is required}"
XRAY_PORT="${XRAY_PORT:-443}"
XRAY_SNI="${XRAY_SNI:-www.nvidia.com}"

XRAY_UUID="${XRAY_UUID:?XRAY_UUID is required}"
XRAY_PRIVATE_KEY="${XRAY_PRIVATE_KEY:?XRAY_PRIVATE_KEY is required}"
XRAY_SHORT_ID="${XRAY_SHORT_ID:?XRAY_SHORT_ID is required}"
XRAY_XHTTP_PATH="${XRAY_XHTTP_PATH:?XRAY_XHTTP_PATH is required}"

XRAY_XHTTP_MODE="${XRAY_XHTTP_MODE:-packet-up}"
XRAY_FINGERPRINT="${XRAY_FINGERPRINT:-chrome}"
XRAY_CLIENT_NAME="${XRAY_CLIENT_NAME:-Arch-XHTTP-Reality}"
XRAY_FORCE_UPDATE="${XRAY_FORCE_UPDATE:-false}"

bool_true() {
  case "${1,,}" in
  1 | true | yes | on) return 0 ;;
  *) return 1 ;;
  esac
}

pkg_installed() {
  local package="$1"
  dpkg-query -W -f='${Status}' "${package}" 2> /dev/null | grep -q 'install ok installed'
}

wait_apt_locks() {
  local locks=(
    /var/lib/dpkg/lock-frontend
    /var/lib/dpkg/lock
    /var/cache/apt/archives/lock
    /var/lib/apt/lists/lock
  )

  local lock
  local waited=0
  local busy=0

  while true; do
    busy=0

    for lock in "${locks[@]}"; do
      if command -v fuser > /dev/null 2>&1; then
        if fuser "${lock}" > /dev/null 2>&1; then
          busy=1
          echo "apt/dpkg lock is busy: ${lock}"
          fuser -v "${lock}" 2> /dev/null || true
        fi
      fi
    done

    if [[ ${busy} -eq 0 ]]; then
      break
    fi

    echo
    ps -eo pid,ppid,stat,etime,cmd | grep -E '[a]pt|[d]pkg|[u]nattended|[p]ackagekit' || true
    echo

    waited=$((waited + 10))

    if [[ ${waited} -gt 900 ]]; then
      echo "Timed out waiting for apt/dpkg locks"
      exit 1
    fi

    echo "waiting for another package process to finish..."
    sleep 10
  done

  dpkg --configure -a || true
}

apt_update() {
  wait_apt_locks
  apt-get -o DPkg::Lock::Timeout=900 update
}

apt_install() {
  wait_apt_locks
  apt-get -o DPkg::Lock::Timeout=900 install -y "$@"
}

install_deps() {
  local missing=()
  local package

  for package in \
    ca-certificates \
    curl \
    openssl \
    iproute2 \
    psmisc; do
    if ! pkg_installed "${package}"; then
      missing+=("${package}")
    fi
  done

  if [[ ${#missing[@]} -eq 0 ]]; then
    echo "Xray dependencies are already installed; skip apt"
    return 0
  fi

  apt_update
  apt_install "${missing[@]}"
}

install_xray() {
  local need_install=0
  local tmp_dir=""
  local install_script=""
  local install_args=()

  if ! command -v xray > /dev/null 2>&1; then
    need_install=1
  fi

  if bool_true "${XRAY_FORCE_UPDATE}"; then
    need_install=1
  fi

  if [[ ${need_install} -eq 0 ]]; then
    echo "Xray is already installed; skip official installer"
    return 0
  fi

  echo "Installing/updating Xray-core with official XTLS installer"

  tmp_dir="$(mktemp -d)"
  install_script="${tmp_dir}/install-release.sh"

  curl -fsSL \
    --retry 5 \
    --retry-delay 5 \
    -o "${install_script}" \
    "https://github.com/XTLS/Xray-install/raw/main/install-release.sh"

  chmod +x "${install_script}"

  install_args=(install)

  if bool_true "${XRAY_FORCE_UPDATE}"; then
    install_args+=(--force)
  fi

  bash "${install_script}" "${install_args[@]}"

  rm -rf "${tmp_dir}"
}

stop_3xui() {
  echo "Stopping old 3x-ui/x-ui if present"

  systemctl disable --now x-ui.service 2> /dev/null || true
  systemctl disable --now 3x-ui.service 2> /dev/null || true

  if command -v docker > /dev/null 2>&1; then
    docker rm -f 3xui_app 2> /dev/null || true
    docker rm -f 3x-ui 2> /dev/null || true
    docker rm -f x-ui 2> /dev/null || true
  fi
}

public_from_private() {
  local private_key="$1"

  xray x25519 -i "${private_key}" |
    awk -F': ' 'tolower($1) ~ /public key/ {print $2}'
}

write_links() {
  local public_key=""
  local encoded_path=""
  local link=""
  local tmp_links=""

  public_key="$(public_from_private "${XRAY_PRIVATE_KEY}")"

  if [[ -z ${public_key} ]]; then
    echo "Failed to derive public key from private key"
    exit 1
  fi

  encoded_path="${XRAY_XHTTP_PATH//\//%2F}"

  link="vless://${XRAY_UUID}@${XRAY_PUBLIC_HOST}:${XRAY_PORT}?encryption=none&security=reality&sni=${XRAY_SNI}&fp=${XRAY_FINGERPRINT}&pbk=${public_key}&sid=${XRAY_SHORT_ID}&type=xhttp&path=${encoded_path}&mode=${XRAY_XHTTP_MODE}#${XRAY_CLIENT_NAME}"

  tmp_links="$(mktemp)"

  cat > "${tmp_links}" << EOF
Xray VLESS + REALITY + XHTTP

Server:
  ${XRAY_PUBLIC_HOST}:${XRAY_PORT}

Client link:
  ${link}

Manual client fields:
  protocol: vless
  address: ${XRAY_PUBLIC_HOST}
  port: ${XRAY_PORT}
  uuid: ${XRAY_UUID}
  encryption: none
  transport: xhttp
  xhttp path: ${XRAY_XHTTP_PATH}
  xhttp mode: ${XRAY_XHTTP_MODE}
  security: reality
  sni: ${XRAY_SNI}
  fingerprint: ${XRAY_FINGERPRINT}
  public key: ${public_key}
  short id: ${XRAY_SHORT_ID}
  flow: empty / none
  mux: disabled

Server config:
  ${config_file}
EOF

  install -m 600 -o root -g root "${tmp_links}" "${links_file}"
  rm -f "${tmp_links}"
}

restart_xray() {
  if [[ ! -f ${config_file} ]]; then
    echo "Missing Xray config: ${config_file}"
    exit 1
  fi

  install -d -m 755 /usr/local/etc/xray
  install -d -m 755 /var/log/xray

  echo "Testing Xray config"
  xray run -test -config "${config_file}"

  systemctl daemon-reload
  systemctl enable xray.service
  systemctl restart xray.service

  echo
  echo "Xray status:"
  systemctl --no-pager --full status xray.service || true

  echo
  echo "Listening ports:"
  ss -tulpn | grep -E "xray|:${XRAY_PORT}" || true
}

main() {
  install_deps
  stop_3xui
  install_xray
  restart_xray
  write_links

  echo
  echo "Xray-core is ready."
  echo "Client link:"
  echo "  sudo cat ${links_file}"
}

main "$@"
