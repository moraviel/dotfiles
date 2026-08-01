#!/usr/bin/env bash
set -euo pipefail

echo "Enabling dms user service (DankMaterialShell)"
systemctl --user enable dms

# Tie dms into the niri user session, same as niri's own systemd integration
# expects: niri.service pulls in dms.service instead of niri spawning
# quickshell itself.
mkdir -p "$HOME/.config/systemd/user/niri.service.wants"
ln -sf /usr/lib/systemd/user/dms.service \
    "$HOME/.config/systemd/user/niri.service.wants/dms.service"
