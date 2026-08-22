#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
WALLPAPERS_SRC="$REPO_ROOT/wallpapers"
WALLPAPERS_DEST="$HOME/.wallpapers"

# Wallpapers are tracked via Git LFS. `make deps` already runs `git lfs pull`,
# but if this hook is invoked on its own (or LFS wasn't set up before the
# initial clone), the files under $WALLPAPERS_SRC may still be tiny text
# pointer stubs instead of real PNGs — smudge them now as a fallback.
if [ -d "$WALLPAPERS_SRC" ] && head -c 200 "$WALLPAPERS_SRC"/catppuccin/mocha/*.png 2>/dev/null | grep -q "git-lfs"; then
    echo "NOTE: wallpapers look like unresolved Git LFS pointers, running 'git lfs pull'" >&2
    if command -v git-lfs >/dev/null 2>&1; then
        (cd "$REPO_ROOT" && git lfs pull)
    else
        echo "NOTE: git-lfs is not installed, cannot resolve wallpapers — run 'make deps' first" >&2
    fi
fi

if [ ! -d "$WALLPAPERS_SRC" ]; then
    echo "NOTE: $WALLPAPERS_SRC missing from the repo checkout" >&2
elif [ -d "$WALLPAPERS_DEST" ]; then
    echo "Wallpapers already present at $WALLPAPERS_DEST"
else
    echo "Copying wallpapers to $WALLPAPERS_DEST"
    cp -r "$WALLPAPERS_SRC" "$WALLPAPERS_DEST"
fi
