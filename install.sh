#!/bin/bash

set -euo pipefail

echo "Installing VPS Energy Monitor..."

if [ "${EUID}" -ne 0 ]; then
  echo "Please run as root using sudo:"
  echo "sudo ./install.sh"
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 is required but was not found."
  exit 1
fi

if ! command -v systemctl >/dev/null 2>&1; then
  echo "systemctl is required but was not found."
  exit 1
fi

install -d -m 755 /var/lib/vps-energy

install -m 755 bin/vps-energy /usr/local/bin/vps-energy

if [ ! -f /etc/vps-energy.conf ]; then
  install -m 644 config/vps-energy.conf.example /etc/vps-energy.conf
  echo "Created /etc/vps-energy.conf"
else
  echo "/etc/vps-energy.conf already exists. Keeping existing configuration."
fi

install -m 644 systemd/vps-energy.service /etc/systemd/system/vps-energy.service

systemctl daemon-reload
systemctl enable --now vps-energy

echo ""
echo "VPS Energy Monitor installed successfully."
echo ""
echo "Try:"
echo "  vps-energy status"
echo "  vps-energy report --period day"
echo ""
echo "Edit configuration:"
echo "  sudo nano /etc/vps-energy.conf"
