#!/usr/bin/env bash
set -euo pipefail

FULL_NAME="Danylo Halytskyi"

current="$(getent passwd "$USER" | cut -d: -f5 | cut -d, -f1)"
if [ "$current" != "$FULL_NAME" ]; then
    echo "Setting account full name to '$FULL_NAME' for $USER"
    sudo usermod -c "$FULL_NAME" "$USER"
else
    echo "Account full name already set to '$FULL_NAME'"
fi
