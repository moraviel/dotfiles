# dotfiles

Personal Arch Linux dotfiles with a two-layer architecture: a `base/` layer
shared by every machine, and a `<hostname>/` layer applied only on the
matching machine. The host layer is picked up automatically from
`/etc/hostname`.

## Machines

| Hostname       | Role                | GPU    | Monitors                          |
|----------------|---------------------|--------|------------------------------------|
| `UXL-4JSYDX3`  | Work laptop         | NVIDIA | 1 built-in + 2-3 external (shared desk, varies by office) |
| `D7JW8FS`      | Personal desktop    | none (integrated) | 2 fixed |

Both machines should be installed with full-disk encryption (LUKS2), same as
the Ubuntu installs they're replacing — see
[docs/disk-encryption.md](docs/disk-encryption.md) for the install-time
procedure. This has to be done before this repo is even cloned; `make` only
configures a system that's already installed.

Desktop stack: **Hyprland** (Wayland compositor) + **Caelestia Shell**
(Quickshell-based bar/launcher/notifications, installed from AUR) +
**greetd** with the **tuigreet** greeter.

## Layout

```
dotfiles/
├── Makefile
├── scripts/
│   ├── deploy-config.sh   # implements `make cfg`
│   └── run-hooks.sh       # implements `make hooks`
├── base/
│   ├── packages           # pacman packages, common to all machines
│   ├── aur-packages       # AUR packages (via paru), common to all machines
│   ├── config/            # mirrors /, deployed first
│   └── hooks/             # <package-name>.sh, run after that package installs
├── UXL-4JSYDX3/
│   ├── packages
│   ├── aur-packages
│   ├── config/            # overlaid on top of base/config, same file wins
│   └── hooks/
└── D7JW8FS/
    ├── packages
    ├── aur-packages
    ├── config/
    └── hooks/
```

## Usage

```sh
git clone <this-repo> ~/dotfiles
cd ~/dotfiles
make            # deps -> pkgs -> aur -> cfg -> hooks
```

Or run steps individually:

```sh
make deps    # git submodules + install paru if missing
make pkgs    # pacman -S base/packages + <hostname>/packages (deduped)
make aur     # paru -S base/aur-packages + <hostname>/aur-packages (deduped)
make cfg     # deploy config/ -> / for base, then for the current hostname
make hooks   # run base/hooks/<pkg>.sh + <hostname>/hooks/<pkg>.sh per package
```

`$HOST` is read from `/etc/hostname` automatically; override it (e.g. for a
dry run against a different host layer) with `make cfg HOST=OTHER-HOST`.

### Config deployment rules (`make cfg`)

- `config/etc/X` → `/etc/X` (written with `sudo`)
- `config/usr/X` → `/usr/X` (written with `sudo`)
- `config/home/{{USER}}/X` → `$HOME/X` (written as the current user, no sudo)
- `{{USER}}` is replaced with `$USER` in every deployed file's *contents* —
  this matters because the two machines have different usernames.
- If a directory contains a `.clean` marker file, everything already in the
  corresponding target directory is deleted before the new files are copied
  in.
- `.gitkeep` and `.clean` are never copied to their targets.
- `base/config` is deployed first, then `<hostname>/config` — a file present
  in both layers is simply overwritten by the host-specific version (there is
  no merging).

### Hooks (`make hooks`)

For every package name in `base/packages`, `base/aur-packages`,
`<hostname>/packages` and `<hostname>/aur-packages`, the corresponding
`base/hooks/<pkg>.sh` and `<hostname>/hooks/<pkg>.sh` are executed if they
exist (base first). Use these for anything a plain package install doesn't
cover: enabling a systemd service, editing `mkinitcpio.conf`, adding the user
to a group, etc.

## Notes

- Monitor layout for `UXL-4JSYDX3` is intentionally left mostly unconfigured
  in `hyprland.conf` since the external monitor setup changes by desk; run
  `hyprctl monitors` after docking and adjust the commented-out `monitor =`
  lines. `D7JW8FS` ships a real 2-monitor layout as a starting point — update
  the connector names to match `hyprctl monitors` on that machine.
- Caelestia Shell only has an official (non-`-git`) AUR package because it
  targets Hyprland specifically — that's why this repo uses Hyprland rather
  than niri. `caelestia-shell`'s AUR dependencies pull in `quickshell-git`,
  `caelestia-cli`, `fish`, `power-profiles-daemon` and a handful of other
  tools automatically; `base/hooks/caelestia-shell.sh` just enables
  `power-profiles-daemon` and seeds an empty `~/.config/caelestia/shell.json`
  if one doesn't exist yet. The shell autostarts via `exec-once = qs -c
  caelestia` in `hyprland.conf`; its keybinds are meant to be wired through
  Hyprland's global shortcuts (see the [Caelestia
  README](https://github.com/caelestia-dots/shell)) rather than through the
  plain `bind =` lines already in `hyprland.conf`.
- `greetd` runs `tuigreet` (official `extra` package, no AUR needed), which
  launches `start-hyprland` (the crash-recovery/safe-mode wrapper Hyprland
  ships since 0.53+, not the bare `Hyprland` binary) — see
  `base/config/etc/greetd/config.toml`.
- `hyprland.conf` uses the classic key/value `.conf` syntax, which Hyprland
  has flagged for removal in 0.57 in favor of a new (currently Lua-based)
  config format — a startup warning about this is expected for now. Not
  worth migrating yet since the replacement format is still new/evolving;
  revisit when it stabilizes.
- Hyprland 0.55 removed the global `dwindle { pseudotile }` option — pseudo
  tiling is now per-window only, via the `pseudo` dispatcher or a window
  rule, so `hyprland.conf` doesn't set it globally anymore.
- Steam/Lutris require the `[multilib]` repo; `make pkgs` enables it
  automatically in `/etc/pacman.conf` when a host's package list requests
  `steam` or `lutris` and it isn't enabled yet.
- Plymouth boot splash and NVIDIA modeset both need a kernel command-line
  change (`splash` / `nvidia_drm.modeset=1`) that's bootloader-specific
  (GRUB vs systemd-boot) — the relevant hooks print what to add instead of
  editing your bootloader config for you.
- Git configuration (`.gitconfig`), GPG/SSH keys, and commit-signing setup
  are **not** managed here — set those up by hand on each machine.
- AUR package names (VS Code, Caelestia Shell, etc.) can be renamed or
  dropped by their maintainers over time; if `make aur` fails on one, check
  `https://aur.archlinux.org` for the current name and update `aur-packages`.
- Several tools are deliberately installed via their own official installer
  scripts in `base/hooks/always.sh` instead of AUR packages, to keep the AUR
  footprint small — each is idempotent (skipped if already on `$PATH`):
  - **JetBrains Toolbox** — tarball downloaded directly from JetBrains
    (resolved via their releases API) into
    `~/.local/share/JetBrains/toolbox-app`, symlinked onto `$PATH` at
    `~/.local/bin/jetbrains-toolbox`, with a `.desktop` entry dropped in.
    Launch it once after `make hooks` — first run does its own IDE-manager
    setup and autostart registration.
  - **Claude Code** — `curl -fsSL https://claude.ai/install.sh | bash`
  - **Opencode** — `curl -fsSL https://opencode.ai/install | bash`
  - **Codex** — `curl -fsSL https://chatgpt.com/codex/install.sh | sh`
- **Bitwarden** is installed from Flathub, not AUR: `flatpak` is in
  `base/packages`, and `base/hooks/flatpak.sh` adds the Flathub remote
  (`flatpak remote-add --if-not-exists flathub ...`) and then installs
  `com.bitwarden.desktop` system-wide.
