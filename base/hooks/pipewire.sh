#!/usr/bin/env bash
set -euo pipefail

echo "Enabling pipewire user services"
systemctl --user enable --now pipewire.socket pipewire-pulse.socket wireplumber.service
