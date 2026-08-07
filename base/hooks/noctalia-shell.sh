#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
WALLPAPERS_SRC="$REPO_ROOT/wallpapers"
WALLPAPERS_DEST="$HOME/.wallpapers"

if [ ! -d "$WALLPAPERS_SRC" ]; then
    echo "NOTE: $WALLPAPERS_SRC missing from the repo checkout" >&2
elif [ -d "$WALLPAPERS_DEST" ]; then
    echo "Wallpapers already present at $WALLPAPERS_DEST"
else
    echo "Copying wallpapers to $WALLPAPERS_DEST"
    cp -r "$WALLPAPERS_SRC" "$WALLPAPERS_DEST"
fi
