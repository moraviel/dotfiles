# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Commands

```bash
make all           # Full install: deps → pkgs → aur → cfg → hooks
make deps          # Install paru (AUR helper) if missing
make pkgs          # Install pacman packages (base + host-specific, deduped)
make aur           # Install AUR packages via paru
make cfg           # Deploy config files with {{USER}} substitution + backups
make hooks         # Run post-install hook scripts
make rollback      # Undo most recent `make cfg`
make rollback-list # List available backup snapshots
```

The `make cfg` target reads `$HOST` from `/etc/hostname` to determine which host-specific layer to apply on top of base.

## Architecture

### Two-Layer Overlay Pattern

```
base/               # Applied to every machine
  packages          # pacman packages (one per line, # comments ok)
  aur-packages      # AUR packages
  config/           # Config files deployed to filesystem
    etc/            # → /etc/ (sudo)
    usr/            # → /usr/ (sudo)
    home/{{USER}}/  # → $HOME/
  hooks/            # Post-install scripts
    <pkg>.sh        # Per-package hook (run if that pkg is installed)
    always.sh       # Always runs, unconditionally

<hostname>/         # Machine-specific overlay, same structure
  LXKA-4JSYDX3/    # Work laptop (NVIDIA, multi-monitor)
  D7JW8FS/          # Personal desktop (gaming, integrated GPU)
```

Host-specific config files **fully replace** (not merge with) base files at the same path.

### Config Deployment (`scripts/deploy-config.sh`)

- Substitutes `{{USER}}` in file *contents* with `$USER`
- Backs up existing files to `~/.local/share/dotfiles-backups/<ISO8601>/` before overwriting
- `.clean` marker files cause the target directory to be wiped before deploying new content
- `.gitkeep` and `.clean` files are never copied to targets
- Files under `etc/` and `usr/` are written with `sudo`

### Hooks (`scripts/run-hooks.sh`)

Hooks run after package installation. Each `<pkg>.sh` is only executed if that package is present in the combined package list. `always.sh` runs unconditionally at the end.

Hook responsibilities include: enabling systemd services, adding users to groups, editing `/etc/` files, and downloading external tools (JetBrains Toolbox, Claude Code, Opencode via curl installers).

### Wallpapers

`wallpapers/` is ~677MB of vendored PNGs tracked with Git LFS (see `.gitattributes`). Organized into `catppuccin/`, `nord/`, and `unthemed/` subdirectories. The `hyprpaper.sh` hook copies them to `~/.wallpapers/` once on first run.

## Desktop Stack

- **Compositor:** Hyprland (config in Lua)
- **Bar:** Waybar
- **Lock/Idle:** hyprlock / hypridle
- **Wallpaper:** hyprpaper
- **Launcher:** Fuzzel
- **Display Manager:** greetd + tuigreet
- **Terminal:** kitty
- **Shell:** zsh + Oh My Zsh + starship prompt
- **Audio:** PipeWire + WirePlumber

## Adding New Configuration

1. **New package:** Add to `base/packages` or `<hostname>/packages`
2. **New config file:** Place at the corresponding path under `base/config/` or `<hostname>/config/`
3. **Post-install setup:** Add `base/hooks/<pkgname>.sh`; make it idempotent (check before acting)
4. **Host-specific override:** Place config at the same relative path under `<hostname>/config/`

## Key Notes

- Monitor layout must be configured manually per machine by running `hyprctl monitors` and editing the host-specific Hyprland config
- NVIDIA setup (LXKA-4JSYDX3): hooks print bootloader/mkinitcpio instructions rather than automating them
- Plymouth/mkinitcpio hooks print rebuild instructions; user must run `mkinitcpio -P` manually
- Rollback only undoes `make cfg` (config files); it does not uninstall packages or undo hooks
- SSH/GPG/Git identity are not managed by this repo — set up manually per machine
