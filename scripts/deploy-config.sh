#!/usr/bin/env bash
# Deploys base/config/ and then $HOST/config/ onto /, replacing {{USER}} with $USER.
#
#   config/etc/X            -> /etc/X          (sudo)
#   config/usr/X             -> /usr/X          (sudo)
#   config/home/{{USER}}/X  -> $HOME/X         (current user, no sudo)
#
# If a directory contains a `.clean` marker file, the corresponding target
# directory is emptied before anything is copied into it.
# `.gitkeep` and `.clean` themselves are never copied.
set -euo pipefail

HOST="${HOST:-$(cat /etc/hostname)}"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Map a path relative to <layer>/config/ to its absolute destination on disk.
target_path() {
    local rel="$1"
    case "$rel" in
        home/'{{USER}}'/*)
            echo "${HOME}/${rel#home/\{\{USER\}\}/}"
            ;;
        home/'{{USER}}')
            echo "${HOME}"
            ;;
        *)
            echo "/${rel}"
            ;;
    esac
}

needs_sudo() {
    case "$1" in
        etc/*|usr/*|etc|usr) return 0 ;;
        *) return 1 ;;
    esac
}

deploy_layer() {
    local layer_dir="$1"
    local config_dir="$layer_dir/config"
    [ -d "$config_dir" ] || return 0

    # Handle .clean markers first: wipe target dirs before copying anything.
    while IFS= read -r -d '' marker; do
        local dir rel target
        dir="$(dirname "$marker")"
        rel="${dir#"$config_dir"/}"
        [ "$rel" = "$dir" ] && rel=""
        target="$(target_path "$rel")"
        [ -d "$target" ] || continue
        if needs_sudo "$rel"; then
            echo "==> [clean] sudo emptying ${target}"
            sudo find "$target" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
        else
            echo "==> [clean] emptying ${target}"
            find "$target" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
        fi
    done < <(find "$config_dir" -type f -name '.clean' -print0)

    # Copy every file, substituting {{USER}} and routing through sudo when needed.
    while IFS= read -r -d '' src_file; do
        local name rel target
        name="$(basename "$src_file")"
        [ "$name" = ".gitkeep" ] && continue
        [ "$name" = ".clean" ] && continue

        rel="${src_file#"$config_dir"/}"
        target="$(target_path "$rel")"

        if needs_sudo "$rel"; then
            echo "==> [sudo] ${rel} -> ${target}"
            sudo mkdir -p "$(dirname "$target")"
            sed "s/{{USER}}/${USER}/g" "$src_file" | sudo tee "$target" >/dev/null
        else
            echo "==> ${rel} -> ${target}"
            mkdir -p "$(dirname "$target")"
            sed "s/{{USER}}/${USER}/g" "$src_file" > "$target"
        fi
    done < <(find "$config_dir" -type f -print0)
}

echo "--- Deploying base config ---"
deploy_layer "$REPO_ROOT/base"

if [ -d "$REPO_ROOT/$HOST" ]; then
    echo "--- Deploying $HOST config ---"
    deploy_layer "$REPO_ROOT/$HOST"
else
    echo "--- No host layer for $HOST, skipping ---"
fi

echo "Done."
