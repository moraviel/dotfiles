#!/usr/bin/env bash
set -euo pipefail

echo "Enabling docker"
sudo systemctl enable --now docker

if ! id -nG "$USER" | grep -qw docker; then
    echo "Adding $USER to the docker group (log out/in to take effect)"
    sudo usermod -aG docker "$USER"
fi
