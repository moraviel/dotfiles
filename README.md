# dotfiles

Personal Arch Linux dotfiles with a two-layer architecture: a `base/` layer
shared by every machine, and a `<hostname>/` layer applied only on the
matching machine. The host layer is picked up automatically from
`/etc/hostname`.

## Machines

| Hostname       | Role                | GPU    | Monitors                          |
|----------------|---------------------|--------|------------------------------------|
| `LXKA-4JSYDX3` | Work laptop         | NVIDIA | 1 built-in + 2-3 external (shared desk, varies by office) |
| `D7JW8FS`      | Personal desktop    | none (integrated) | 2 fixed |

Both machines should be installed with full-disk encryption (LUKS2), same as
the Ubuntu installs they're replacing — see
[docs/disk-encryption.md](docs/disk-encryption.md) for the install-time
procedure. This has to be done before this repo is even cloned; `make` only
configures a system that's already installed.

Desktop stack: **Hyprland** (Wayland compositor) + **Waybar** (bar) +
**Mako** (notifications) + **Walker** (app launcher) + **hyprlock**/**hypridle**
(lock/idle) + **hyprpaper** (wallpaper) + **greetd** with the **tuigreet**
greeter. Theme is Catppuccin Mocha throughout.

## Layout

```
dotfiles/
├── Makefile
├── scripts/
│   ├── deploy-config.sh   # implements `make cfg`
│   ├── rollback-config.sh # implements `make rollback`
│   └── run-hooks.sh       # implements `make hooks`
├── wallpapers/            # vendored copy of github.com/teowelton/Wallpapers
│                          # (whole repo, ~677MB — copied to ~/.wallpapers/
│                          # by base/hooks/hyprpaper.sh)
├── base/
│   ├── packages           # pacman packages, common to all machines
│   ├── aur-packages       # AUR packages (via paru), common to all machines
│   ├── config/            # mirrors /, deployed first
│   └── hooks/             # <package-name>.sh, run after that package installs
├── LXKA-4JSYDX3/
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
- Every file about to be overwritten (or deleted by a `.clean` wipe) is
  backed up first — see [Rolling back](#rolling-back-make-cfg) below.

### Rolling back `make cfg`

Before `make cfg` overwrites or deletes an existing file, it snapshots the
current copy to `~/.local/share/dotfiles-backups/<timestamp>/<same absolute
path>`. If a change turns out to be broken:

```sh
make rollback-list      # show available snapshots, newest first
make rollback           # restore the most recent snapshot
make rollback SNAPSHOT=20260803T202439   # restore a specific one
```

This only undoes files `make cfg` touched — it doesn't uninstall packages or
undo what hooks did to system state (`mkinitcpio.conf` changes from
`plymouth.sh`/`nvidia-open.sh` have their own `.bak` file alongside the
original; systemd services enabled by hooks stay enabled). The intended
workflow for a bad change is:

```sh
make rollback        # 1. undo the config changes on this machine
git pull              # 2. (or checkout an earlier commit) to get the fix
make                  # 3. reapply
```

Snapshots accumulate under `~/.local/share/dotfiles-backups/` and are never
deleted automatically — prune old ones by hand once you're confident you
won't need them.

### Hooks (`make hooks`)

For every package name in `base/packages`, `base/aur-packages`,
`<hostname>/packages` and `<hostname>/aur-packages`, the corresponding
`base/hooks/<pkg>.sh` and `<hostname>/hooks/<pkg>.sh` are executed if they
exist (base first). Use these for anything a plain package install doesn't
cover: enabling a systemd service, editing `mkinitcpio.conf`, adding the user
to a group, etc.

## Notes

- Monitor layout for `LXKA-4JSYDX3` is intentionally left mostly unconfigured
  in `hyprland.conf` since the external monitor setup changes by desk; run
  `hyprctl monitors` after docking and adjust the commented-out `monitor =`
  lines. `D7JW8FS` ships a real 2-monitor layout as a starting point — update
  the connector names to match `hyprctl monitors` on that machine.
- **Waybar** (`base/config/home/{{USER}}/.config/waybar/config.jsonc` +
  `style.css`) — top bar, Catppuccin Mocha styled: Arch logo (Nerd Font glyph
  ``, verified against the canonical
  [nerd-fonts glyphnames.json](https://github.com/ryanoasis/nerd-fonts/blob/master/glyphnames.json)
  rather than guessed) + workspaces (dot style) + active window on the left,
  clock centered, tray/mpris/notification-toggle/bluetooth/network/volume/
  battery on the right. `mpris` needs `playerctl`; `bluetooth`'s click opens
  `blueman-manager`; `network`'s click opens `nm-connection-editor`;
  `pulseaudio`'s click opens `pavucontrol` — all four packages are in
  `base/packages` alongside `waybar` itself.
- **Mako** (`base/config/home/{{USER}}/.config/mako/config`) — notification
  daemon, Catppuccin Mocha colors, red border + no timeout on
  `[urgency=critical]`. Waybar's bell icon toggles do-not-disturb via
  `makoctl mode -t do-not-disturb`, it doesn't show a history/popover.
- **Walker** (AUR `walker-bin`, maintained by its own upstream author) — app
  launcher bound to `$mod+D`. Backed by `elephant` (auto-installed as a
  dependency) with only a few providers installed on purpose instead of
  `elephant-all-bin` (which pulls ~20 packages including 1Password/ProtonPass
  providers nobody here uses): `elephant-desktopapplications-bin` (app
  launching), `-runner-bin`, `-calc-bin`, `-files-bin`. Add more
  `elephant-<provider>-bin` packages later if you want clipboard/websearch/
  bluetooth providers inside the launcher too — see `providers.default` in
  `base/config/home/{{USER}}/.config/walker/config.toml`, which only lists
  what's actually installed. Theme is a 5-color-variable override
  (`themes/catppuccin-mocha/style.css`) on top of Walker's bundled `default`
  theme layout — no custom XML layout needed. `elephant-bin` ships a bare
  binary with no systemd service or autostart of its own — Walker just shows
  "Waiting for elephant" forever if nothing starts it, so `hyprland.conf` has
  `exec-once = elephant` right before the `hyprpaper` line.
- **hyprpaper** sets the wallpaper: `base/config/home/{{USER}}/.config/hypr/hyprpaper.conf`
  points at
  `~/.wallpapers/catppuccin/mocha/kurzgesagt/Cloudy_Quasar_1-Catppuccin_Mocha.png`.
  That path only exists after `base/hooks/hyprpaper.sh` copies the
  `wallpapers/` directory (vendored directly in this repo, not a submodule —
  it's ~677MB, so cloning this repo takes a while) to `~/.wallpapers/` (first
  run only — it skips the copy if `~/.wallpapers` already exists, so it won't
  stomp on wallpapers you add there yourself).
- **hyprlock** (`hyprlock.conf`) shows the same wallpaper blurred, a clock,
  and a password field; bound to `$mod+L`. **hypridle** (`hypridle.conf`)
  locks after 5 minutes idle and turns the display off 30 seconds after that
  — both configs are in `base/config/home/{{USER}}/.config/hypr/`.
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
- `base/hooks/xdg-user-dirs.sh` creates `~/Desktop`, `Documents`, `Downloads`,
  `Music`, `Pictures`, `Public`, `Templates`, `Videos` and writes
  `~/.config/user-dirs.dirs` pointing at them directly — this bypasses
  `xdg-user-dirs-update`'s own locale-based translation (which would
  otherwise create localized names like `Рабочий стол` instead of `Desktop`
  depending on system locale), since these exact English names were asked
  for explicitly. `xdg-user-dirs` (the package) is still installed for the
  `xdg-user-dir` CLI tool other apps expect to find.
- Git configuration (`.gitconfig`), GPG/SSH keys, and commit-signing setup
  are **not** managed here — set those up by hand on each machine.
- AUR package names (VS Code, plymouth themes, etc.) can be renamed or
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
