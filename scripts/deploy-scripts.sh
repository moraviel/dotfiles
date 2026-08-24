#!/usr/bin/env bash
# Deploys base/scripts/ and then $HOST/scripts/ into ~/.local/bin, making
# each file executable. Files are copied flat (subdirectories are not
# supported) and a $HOST script with the same name as a base script
# overwrites it, so hosts can override a base script.
#
# `.gitkeep` is never copied.
set -euo pipefail

HOST="${HOST:-$(cat /etc/hostname)}"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BIN_DIR="${BIN_DIR:-$HOME/.local/bin}"

deploy_layer() {
    local layer_dir="$1"
    local scripts_dir="$layer_dir/scripts"
    [ -d "$scripts_dir" ] || return 0

    mkdir -p "$BIN_DIR"
    while IFS= read -r -d '' src_file; do
        local name="$(basename "$src_file")"
        [ "$name" = ".gitkeep" ] && continue

        echo "==> ${src_file#"$REPO_ROOT"/} -> $BIN_DIR/$name"
        cp "$src_file" "$BIN_DIR/$name"
        chmod +x "$BIN_DIR/$name"
    done < <(find "$scripts_dir" -maxdepth 1 -type f -print0)
}

echo "--- Deploying base scripts ---"
deploy_layer "$REPO_ROOT/base"

if [ -d "$REPO_ROOT/$HOST" ]; then
    echo "--- Deploying $HOST scripts ---"
    deploy_layer "$REPO_ROOT/$HOST"
else
    echo "--- No host layer for $HOST, skipping ---"
fi

echo "Done."
