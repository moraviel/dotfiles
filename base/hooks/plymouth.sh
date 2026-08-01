#!/usr/bin/env bash
set -euo pipefail

MKINITCPIO=/etc/mkinitcpio.conf

if ! grep -q '\bplymouth\b' "$MKINITCPIO"; then
    echo "Adding plymouth hook to $MKINITCPIO (backup at ${MKINITCPIO}.bak)"
    sudo cp "$MKINITCPIO" "${MKINITCPIO}.bak"
    sudo sed -i -E 's/^(HOOKS=\([^)]*\b(systemd|udev)\b)/\1 plymouth/' "$MKINITCPIO"
    sudo mkinitcpio -P
else
    echo "plymouth hook already present in $MKINITCPIO"
fi

cat <<'EOF'
NOTE: also add `splash` (and optionally `quiet`) to your bootloader's kernel
command line to see the plymouth splash screen, e.g. in /etc/kernel/cmdline
(systemd-boot) or GRUB_CMDLINE_LINUX_DEFAULT (GRUB), then regenerate the
bootloader config. This is bootloader-specific and not done automatically.

Pick a theme with: sudo plymouth-set-default-theme -R <theme-name>
(available themes come from the plymouth-themes-adi1090x-git AUR package)
EOF
