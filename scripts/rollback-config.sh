#!/usr/bin/env bash
# Restores files from a snapshot taken by scripts/deploy-config.sh, undoing
# the config changes made by a `make cfg` run.
#
# Usage:
#   scripts/rollback-config.sh          # restore the most recent snapshot
#   scripts/rollback-config.sh list     # list available snapshots, newest first
#   scripts/rollback-config.sh <name>   # restore a specific snapshot (see `list`)
set -euo pipefail

BACKUP_ROOT="${BACKUP_ROOT:-$HOME/.local/share/dotfiles-backups}"

needs_sudo() {
    case "$1" in
        /etc/*|/usr/*) return 0 ;;
        *) return 1 ;;
    esac
}

list_snapshots() {
    [ -d "$BACKUP_ROOT" ] || return 0
    find "$BACKUP_ROOT" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort -r
}

if [ "${1:-}" = "list" ]; then
    list_snapshots
    exit 0
fi

if [ -n "${1:-}" ]; then
    snapshot="$BACKUP_ROOT/$1"
else
    latest="$(list_snapshots | head -1)"
    if [ -z "$latest" ]; then
        echo "No snapshots found under $BACKUP_ROOT — nothing to roll back." >&2
        exit 1
    fi
    snapshot="$BACKUP_ROOT/$latest"
fi

if [ ! -d "$snapshot" ]; then
    echo "Snapshot not found: $snapshot" >&2
    echo "Available snapshots:" >&2
    list_snapshots >&2
    exit 1
fi

echo "Restoring from $snapshot"

while IFS= read -r -d '' backup_file; do
    target="${backup_file#"$snapshot"}"
    if needs_sudo "$target"; then
        echo "==> [sudo] restoring $target"
        sudo mkdir -p "$(dirname "$target")"
        sudo cp -a "$backup_file" "$target"
    else
        echo "==> restoring $target"
        mkdir -p "$(dirname "$target")"
        cp -a "$backup_file" "$target"
    fi
done < <(find "$snapshot" -type f -print0)

echo "Done. Restored snapshot: $(basename "$snapshot")"
