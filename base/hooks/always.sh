#!/usr/bin/env bash
# Machine setup not tied to a specific pacman/AUR package.
set -euo pipefail

TOOLBOX_DIR="$HOME/.local/share/JetBrains/toolbox-app"
TOOLBOX_BIN="$TOOLBOX_DIR/bin/jetbrains-toolbox"
TOOLBOX_LINK="$HOME/.local/bin/jetbrains-toolbox"
TOOLBOX_DESKTOP="$HOME/.local/share/applications/jetbrains-toolbox.desktop"

if [ -x "$TOOLBOX_BIN" ]; then
    echo "JetBrains Toolbox already installed at $TOOLBOX_BIN"
else
    echo "Fetching latest JetBrains Toolbox download link"
    release_json="$(curl -fsSL 'https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release')"
    url="$(echo "$release_json" | jq -r '.TBA[0].downloads.linux.link')"

    if [ -z "$url" ] || [ "$url" = "null" ]; then
        echo "Could not resolve JetBrains Toolbox download URL, skipping" >&2
    else
        echo "Downloading JetBrains Toolbox from $url"
        tmpdir="$(mktemp -d)"
        curl -fsSL "$url" -o "$tmpdir/toolbox.tar.gz"
        tar -xzf "$tmpdir/toolbox.tar.gz" -C "$tmpdir"

        # Archive contains a single top-level jetbrains-toolbox-<version>/ dir
        # with a bin/ subdir holding the jetbrains-toolbox binary, icon and
        # a bundled (relative-path) .desktop file.
        extracted_dir="$(find "$tmpdir" -maxdepth 1 -type d -name 'jetbrains-toolbox-*')"
        mkdir -p "$(dirname "$TOOLBOX_DIR")"
        rm -rf "$TOOLBOX_DIR"
        mv "$extracted_dir" "$TOOLBOX_DIR"
        rm -rf "$tmpdir"

        chmod +x "$TOOLBOX_BIN"
        mkdir -p "$(dirname "$TOOLBOX_LINK")"
        ln -sf "$TOOLBOX_BIN" "$TOOLBOX_LINK"

        mkdir -p "$(dirname "$TOOLBOX_DESKTOP")"
        sed "s|Icon=jetbrains-toolbox|Icon=$TOOLBOX_DIR/bin/toolbox.svg|" \
            "$TOOLBOX_DIR/bin/jetbrains-toolbox.desktop" > "$TOOLBOX_DESKTOP"

        echo "Installed JetBrains Toolbox to $TOOLBOX_DIR (symlinked at $TOOLBOX_LINK)"
        echo "Launch it once (jetbrains-toolbox) to finish first-run setup (it manages its own autostart from there)."
    fi
fi

# Claude Code, Opencode and Codex are installed via their own official
# installer scripts instead of AUR packages, to keep the AUR footprint down.
# All three install to $HOME/.local/bin, so make sure that's on PATH
# (it is, via base/config/home/{{USER}}/.zshrc).

if command -v claude >/dev/null 2>&1; then
    echo "Claude Code already installed: $(command -v claude)"
else
    echo "Installing Claude Code"
    curl -fsSL https://claude.ai/install.sh | bash
fi

if command -v opencode >/dev/null 2>&1; then
    echo "Opencode already installed: $(command -v opencode)"
else
    echo "Installing Opencode"
    curl -fsSL https://opencode.ai/install | bash
fi

if command -v codex >/dev/null 2>&1; then
    echo "Codex already installed: $(command -v codex)"
else
    echo "Installing Codex"
    curl -fsSL https://chatgpt.com/codex/install.sh | sh
fi
