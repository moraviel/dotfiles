#!/usr/bin/env bash
set -euo pipefail

MKINITCPIO=/etc/mkinitcpio.conf
NVIDIA_MODULES="nvidia nvidia_modeset nvidia_uvm nvidia_drm"

if ! grep -q 'nvidia_drm' "$MKINITCPIO"; then
    echo "Adding NVIDIA modules to $MKINITCPIO (backup at ${MKINITCPIO}.bak)"
    sudo cp "$MKINITCPIO" "${MKINITCPIO}.bak"
    sudo sed -i -E "s/^MODULES=\(([^)]*)\)/MODULES=(\1 ${NVIDIA_MODULES})/" "$MKINITCPIO"
    sudo mkinitcpio -P
else
    echo "NVIDIA modules already present in $MKINITCPIO"
fi

cat <<'EOF'
NOTE: for Hyprland (Wayland) to work well with NVIDIA, also add
`nvidia_drm.modeset=1 nvidia_drm.fbdev=1` to your bootloader's kernel
command line (systemd-boot: /etc/kernel/cmdline, GRUB:
GRUB_CMDLINE_LINUX_DEFAULT) and regenerate the bootloader config.
This is bootloader-specific and not done automatically. The Hyprland env
vars (LIBVA_DRIVER_NAME, __GLX_VENDOR_LIBRARY_NAME, etc.) are already set
in LXKA-4JSYDX3's hyprland.conf.
EOF
