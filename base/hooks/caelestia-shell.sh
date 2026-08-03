#!/usr/bin/env bash
set -euo pipefail

# power-profiles-daemon is pulled in transitively as an AUR dependency of
# caelestia-shell; enable it since Caelestia's power widget expects it running.
echo "Enabling power-profiles-daemon"
sudo systemctl enable --now power-profiles-daemon

CAELESTIA_CONFIG="$HOME/.config/caelestia/shell.json"
if [ ! -f "$CAELESTIA_CONFIG" ]; then
    echo "Creating default Caelestia config at $CAELESTIA_CONFIG"
    mkdir -p "$(dirname "$CAELESTIA_CONFIG")"
    echo '{}' > "$CAELESTIA_CONFIG"
fi
