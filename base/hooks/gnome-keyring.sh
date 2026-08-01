#!/usr/bin/env bash
set -euo pipefail

echo "Enabling gnome-keyring-daemon user services"
systemctl --user enable --now gnome-keyring-daemon.socket || true

cat <<'EOF'
NOTE: to unlock the keyring automatically on login, add the following line
to /etc/pam.d/greetd (or your login PAM stack) after `auth include ...`:

    auth optional pam_gnome_keyring.so
    session optional pam_gnome_keyring.so auto_start

This is not done automatically since it edits a system PAM file.
EOF
