#!/usr/bin/env bash
set -euo pipefail

echo "Adding Flathub remote"
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

echo "Installing Qalculate from Flathub"
flatpak install -y flathub io.github.Qalculate
