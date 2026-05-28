#!/usr/bin/env bash
set -euo pipefail

sudo grub-mkconfig -o /boot/grub/grub.cfg
