#!/usr/bin/env bash
set -euo pipefail

echo "[xray-assets-cleanup] removing managed Xray assets"

sudo rm -f /etc/xray/geosite.dat
sudo rm -f /etc/xray/geoip.dat

echo "[xray-assets-cleanup] done"
