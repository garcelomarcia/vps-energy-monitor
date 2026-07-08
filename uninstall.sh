#!/bin/bash

set -euo pipefail

echo "Uninstalling VPS Energy Monitor..."

if [ "${EUID}" -ne 0 ]; then
  echo "Please run as root using sudo:"
  echo "sudo ./uninstall.sh"
  exit 1
fi

systemctl stop vps-energy || true
systemctl disable vps-energy || true

rm -f /etc/systemd/system/vps-energy.service
rm -f /usr/local/bin/vps-energy

systemctl daemon-reload

echo ""
echo "VPS Energy Monitor was uninstalled."
echo ""
echo "The database and config were kept:"
echo "  /var/lib/vps-energy/"
echo "  /etc/vps-energy.conf"
echo ""
echo "To remove them manually:"
echo "  sudo rm -rf /var/lib/vps-energy"
echo "  sudo rm -f /etc/vps-energy.conf"
