#!/usr/bin/env bash
# For every package listed in base/packages, base/aur-packages, $HOST/packages
# and $HOST/aur-packages, run base/hooks/<pkg>.sh and $HOST/hooks/<pkg>.sh if
# they exist (in that order). Missing hooks are silently skipped.
set -euo pipefail

HOST="${HOST:-$(cat /etc/hostname)}"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

list_files=(
    "$REPO_ROOT/base/packages"
    "$REPO_ROOT/base/aur-packages"
    "$REPO_ROOT/$HOST/packages"
    "$REPO_ROOT/$HOST/aur-packages"
)

mapfile -t packages < <(
    cat "${list_files[@]}" 2>/dev/null | sed '/^\s*#/d;/^\s*$/d' | sort -u
)

for pkg in "${packages[@]}"; do
    for hook in "$REPO_ROOT/base/hooks/${pkg}.sh" "$REPO_ROOT/$HOST/hooks/${pkg}.sh"; do
        if [ -f "$hook" ]; then
            echo "==> running hook: ${hook#"$REPO_ROOT"/}"
            bash "$hook"
        fi
    done
done

echo "Done."
