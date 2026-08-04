#!/usr/bin/env bash
set -euo pipefail

echo "Enabling bluetooth"
sudo systemctl enable --now bluetooth
