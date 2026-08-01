#!/usr/bin/env bash
set -euo pipefail
echo "Enabling sshd"
sudo systemctl enable --now sshd
