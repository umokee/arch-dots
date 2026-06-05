#!/usr/bin/env bash
set -euo pipefail

SUDO=(sudo)
if [[ ${EUID} -eq 0 ]]; then
  SUDO=()
fi

export DEBIAN_FRONTEND=noninteractive

env_file="/etc/archctl/xray-core.env"
generated_file="/etc/archctl/xray-core.generated.env"
config_file="/usr/local/etc/xray/config.json"
links_file="/root/xray-client-links.txt"

if [[ ! -f ${env_file} ]]; then
  echo "Missing ${env_file}"
  exit 1
fi

# shellcheck disable=SC1090
source "${env_file}"

if [[ -f ${generated_file} ]]; then
  # shellcheck disable=SC1090
  source "${generated_file}"
fi

bool_true() {
  case "${1,,}" in
  1 | true | yes | on)
    return 0
    ;;
  *)
    return 1
    ;;
  esac
}

wait_apt_locks() {
  local waited=0

  while
    pgrep -x apt > /dev/null 2>&1 ||
      pgrep -x apt-get > /dev/null 2>&1 ||
      pgrep -x dpkg > /dev/null 2>&1 ||
      pgrep -x unattended-upgr > /dev/null 2>&1
  do
    waited=$((waited + 10))

    if [[ ${waited} -gt 1800 ]]; then
      echo "Timed out waiting for apt/dpkg process"
      exit 1
    fi

    echo "apt/dpkg is busy, waiting..."
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

install_deps() {
  apt_update
  apt_install \
    ca-certificates \
    curl \
    openssl \
    iproute2
}

install_xray() {
  local need_install=0

  if ! command -v xray > /dev/null 2>&1; then
    need_install=1
  fi

  if bool_true "${XRAY_FORCE_UPDATE}"; then
    need_install=1
  fi

  if [[ ${need_install} -eq 0 ]]; then
    echo "Xray is already installed"
    return 0
  fi

  echo "Installing/updating Xray-core via official XTLS installer"

  curl -fsSL \
    https://github.com/XTLS/Xray-install/raw/main/install-release.sh \
    -o /tmp/xray-install-release.sh

  chmod +x /tmp/xray-install-release.sh

  "${SUDO[@]}" bash /tmp/xray-install-release.sh install
}

stop_3xui() {
  echo "Stopping old 3x-ui/x-ui if present"

  "${SUDO[@]}" systemctl disable --now x-ui.service 2> /dev/null || true
  "${SUDO[@]}" systemctl disable --now 3x-ui.service 2> /dev/null || true

  if command -v docker > /dev/null 2>&1; then
    "${SUDO[@]}" docker rm -f 3xui_app 2> /dev/null || true
  fi
}

need_auto() {
  [[ ${1} == "auto" || -z ${1} ]]
}

generate_uuid() {
  cat /proc/sys/kernel/random/uuid
}

generate_short_id() {
  openssl rand -hex 8
}

generate_xhttp_path() {
  printf '/%s\n' "$(openssl rand -hex 8)"
}

generate_x25519_pair() {
  xray x25519
}

public_from_private() {
  local private_key="$1"
  xray x25519 -i "${private_key}" | awk -F': ' '/Public key/ {print $2}'
}

prepare_state() {
  actual_uuid="${XRAY_UUID}"
  actual_private_key="${XRAY_PRIVATE_KEY}"
  actual_public_key="${XRAY_GENERATED_PUBLIC_KEY:-}"
  actual_short_id="${XRAY_SHORT_ID}"
  actual_xhttp_path="${XRAY_XHTTP_PATH}"

  if need_auto "${actual_uuid}"; then
    actual_uuid="${XRAY_GENERATED_UUID:-}"
    if [[ -z ${actual_uuid} ]]; then
      actual_uuid="$(generate_uuid)"
    fi
  fi

  if need_auto "${actual_private_key}"; then
    actual_private_key="${XRAY_GENERATED_PRIVATE_KEY:-}"
    actual_public_key="${XRAY_GENERATED_PUBLIC_KEY:-}"

    if [[ -z ${actual_private_key} || -z ${actual_public_key} ]]; then
      pair="$(generate_x25519_pair)"
      actual_private_key="$(printf '%s\n' "${pair}" | awk -F': ' '/Private key/ {print $2}')"
      actual_public_key="$(printf '%s\n' "${pair}" | awk -F': ' '/Public key/ {print $2}')"
    fi
  else
    actual_public_key="$(public_from_private "${actual_private_key}")"
  fi

  if need_auto "${actual_short_id}"; then
    actual_short_id="${XRAY_GENERATED_SHORT_ID:-}"
    if [[ -z ${actual_short_id} ]]; then
      actual_short_id="$(generate_short_id)"
    fi
  fi

  if need_auto "${actual_xhttp_path}"; then
    actual_xhttp_path="${XRAY_GENERATED_XHTTP_PATH:-}"
    if [[ -z ${actual_xhttp_path} ]]; then
      actual_xhttp_path="$(generate_xhttp_path)"
    fi
  fi

  if [[ -z ${actual_uuid} ]]; then
    echo "Failed to generate UUID"
    exit 1
  fi

  if [[ -z ${actual_private_key} || -z ${actual_public_key} ]]; then
    echo "Failed to generate X25519 key pair"
    exit 1
  fi

  if [[ -z ${actual_short_id} ]]; then
    echo "Failed to generate short_id"
    exit 1
  fi

  if [[ ${actual_xhttp_path} != /* ]]; then
    actual_xhttp_path="/${actual_xhttp_path}"
  fi

  tmp_generated="$(mktemp)"

  cat > "${tmp_generated}" << EOF
XRAY_GENERATED_UUID='${actual_uuid}'
XRAY_GENERATED_PRIVATE_KEY='${actual_private_key}'
XRAY_GENERATED_PUBLIC_KEY='${actual_public_key}'
XRAY_GENERATED_SHORT_ID='${actual_short_id}'
XRAY_GENERATED_XHTTP_PATH='${actual_xhttp_path}'
EOF

  "${SUDO[@]}" install -m 600 -o root -g root "${tmp_generated}" "${generated_file}"
  rm -f "${tmp_generated}"
}

write_config() {
  "${SUDO[@]}" install -d -m 755 /usr/local/etc/xray

  tmp_config="$(mktemp)"

  cat > "${tmp_config}" << EOF
{
  "log": {
    "loglevel": "warning"
  },
  "dns": {
    "queryStrategy": "${XRAY_DNS_STRATEGY}",
    "servers": [
      "1.1.1.1",
      "8.8.8.8"
    ]
  },
  "routing": {
    "domainStrategy": "IPIfNonMatch",
    "rules": [
      {
        "type": "field",
        "protocol": [
          "bittorrent"
        ],
        "outboundTag": "block"
      }
    ]
  },
  "inbounds": [
    {
      "tag": "vless-xhttp-reality",
      "listen": "${XRAY_LISTEN}",
      "port": ${XRAY_PORT},
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "${actual_uuid}",
            "email": "${XRAY_CLIENT_NAME}"
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "xhttp",
        "security": "reality",
        "xhttpSettings": {
          "path": "${actual_xhttp_path}",
          "mode": "${XRAY_XHTTP_MODE}"
        },
        "realitySettings": {
          "show": false,
          "target": "${XRAY_TARGET}",
          "serverNames": [
            "${XRAY_SNI}"
          ],
          "privateKey": "${actual_private_key}",
          "shortIds": [
            "${actual_short_id}"
          ]
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls",
          "quic"
        ]
      }
    }
  ],
  "outbounds": [
    {
      "tag": "direct",
      "protocol": "freedom",
      "settings": {
        "domainStrategy": "${XRAY_DNS_STRATEGY}"
      }
    },
    {
      "tag": "block",
      "protocol": "blackhole"
    }
  ]
}
EOF

  echo "Testing Xray config"
  "${SUDO[@]}" xray run -test -config "${tmp_config}"

  "${SUDO[@]}" install -m 644 -o root -g root "${tmp_config}" "${config_file}"
  rm -f "${tmp_config}"
}

write_links() {
  encoded_path="${actual_xhttp_path//\//%2F}"

  link="vless://${actual_uuid}@${XRAY_PUBLIC_HOST}:${XRAY_PORT}?encryption=none&security=reality&sni=${XRAY_SNI}&fp=${XRAY_FINGERPRINT}&pbk=${actual_public_key}&sid=${actual_short_id}&type=xhttp&path=${encoded_path}&mode=${XRAY_XHTTP_MODE}#${XRAY_CLIENT_NAME}"

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
  uuid: ${actual_uuid}
  encryption: none
  transport: xhttp
  xhttp path: ${actual_xhttp_path}
  xhttp mode: ${XRAY_XHTTP_MODE}
  security: reality
  sni: ${XRAY_SNI}
  fingerprint: ${XRAY_FINGERPRINT}
  public key: ${actual_public_key}
  short id: ${actual_short_id}
  flow: empty / none

Server config:
  ${config_file}

Generated state:
  ${generated_file}
EOF

  "${SUDO[@]}" install -m 600 -o root -g root "${tmp_links}" "${links_file}"
  rm -f "${tmp_links}"
}

restart_xray() {
  "${SUDO[@]}" systemctl daemon-reload
  "${SUDO[@]}" systemctl enable xray.service
  "${SUDO[@]}" systemctl restart xray.service

  echo
  echo "Xray status:"
  "${SUDO[@]}" systemctl --no-pager --full status xray.service || true

  echo
  echo "Listening ports:"
  "${SUDO[@]}" ss -tulpn | grep -E "xray|:${XRAY_PORT}" || true
}

main() {
  install_deps
  stop_3xui
  install_xray
  prepare_state
  write_config
  write_links
  restart_xray

  echo
  echo "Xray-core is ready."
  echo "Client link:"
  echo "  sudo cat ${links_file}"
}

main "$@"
