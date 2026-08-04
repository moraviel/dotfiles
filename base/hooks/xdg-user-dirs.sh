#!/usr/bin/env bash
# Creates the standard XDG user directories with plain English names
# regardless of system locale, and writes ~/.config/user-dirs.dirs so
# GTK/Qt file dialogs and other XDG-aware apps agree on the same paths.
set -euo pipefail

DIRS=(Desktop Documents Downloads Music Pictures Public Templates Videos)

for d in "${DIRS[@]}"; do
    mkdir -p "$HOME/$d"
done

CONFIG_DIR="$HOME/.config"
mkdir -p "$CONFIG_DIR"
cat > "$CONFIG_DIR/user-dirs.dirs" <<EOF
XDG_DESKTOP_DIR="\$HOME/Desktop"
XDG_DOCUMENTS_DIR="\$HOME/Documents"
XDG_DOWNLOAD_DIR="\$HOME/Downloads"
XDG_MUSIC_DIR="\$HOME/Music"
XDG_PICTURES_DIR="\$HOME/Pictures"
XDG_PUBLICSHARE_DIR="\$HOME/Public"
XDG_TEMPLATES_DIR="\$HOME/Templates"
XDG_VIDEOS_DIR="\$HOME/Videos"
EOF

echo "Created XDG user directories: ${DIRS[*]}"
