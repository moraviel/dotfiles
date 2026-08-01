#!/usr/bin/env bash
set -euo pipefail

echo "Enabling NetworkManager"
sudo systemctl enable --now NetworkManager
