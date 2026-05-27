#!/usr/bin/env bash
set -euo pipefail

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

curl -L \
  -o "$tmp_dir/geosite.dat" \
  "https://github.com/runetfreedom/russia-v2ray-rules-dat/releases/latest/download/geosite.dat"

curl -L \
  -o "$tmp_dir/geoip.dat" \
  "https://github.com/runetfreedom/russia-v2ray-rules-dat/releases/latest/download/geoip.dat"

sudo install -d -m 755 /etc/xray
sudo install -m 644 "$tmp_dir/geosite.dat" /etc/xray/geosite.dat
sudo install -m 644 "$tmp_dir/geoip.dat" /etc/xray/geoip.dat
