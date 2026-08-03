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
#
# Before overwriting any file that already exists, its current content is
# snapshotted under $BACKUP_ROOT/<timestamp>/<same absolute path> so a run
# can be undone with `make rollback` / scripts/rollback-config.sh.
set -euo pipefail

HOST="${HOST:-$(cat /etc/hostname)}"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_ROOT="${BACKUP_ROOT:-$HOME/.local/share/dotfiles-backups}"
SNAPSHOT_DIR="$BACKUP_ROOT/$(date +%Y%m%dT%H%M%S)"
SNAPSHOT_USED=0

# Copy $1 (an existing target file about to be overwritten) into this run's
# snapshot dir, mirroring its absolute path. No-ops if $1 doesn't exist yet.
backup_target() {
    local target="$1"
    [ -e "$target" ] || return 0
    local backup_path="$SNAPSHOT_DIR$target"
    # backup_path always lives under $HOME, regardless of whether the target
    # itself needs sudo — so the directory is always created as the normal
    # user. Only the actual copy (reading a possibly root-owned source) goes
    # through sudo, and the resulting file is chowned back to the user.
    mkdir -p "$(dirname "$backup_path")"
    if needs_sudo "${target#/}"; then
        sudo cp -a "$target" "$backup_path"
        sudo chown "$USER:$USER" "$backup_path"
    else
        cp -a "$target" "$backup_path"
    fi
    SNAPSHOT_USED=1
}

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
        echo "==> [clean] backing up and emptying ${target}"
        while IFS= read -r -d '' existing; do
            backup_target "$existing"
        done < <(find "$target" -mindepth 1 -type f -print0)
        if needs_sudo "$rel"; then
            sudo find "$target" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
        else
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
        backup_target "$target"

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

if [ "$SNAPSHOT_USED" = 1 ]; then
    echo "Backed up previous files to $SNAPSHOT_DIR"
    echo "Undo this run with: make rollback"
fi

echo "Done."
