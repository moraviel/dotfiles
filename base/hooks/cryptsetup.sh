#!/usr/bin/env bash
set -euo pipefail

if ! findmnt -no SOURCE / | grep -q '/dev/mapper/'; then
    cat <<'EOF'
NOTE: root does not appear to be on a LUKS mapper device. Disk encryption
has to be set up during the Arch install itself, not by this hook — see
docs/disk-encryption.md for the full procedure.
EOF
fi
