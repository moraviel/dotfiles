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

Desktop stack: **Hyprland** (Wayland compositor) + **Noctalia** (a
Quickshell-based shell providing the bar, launcher, control center, lock
screen, idle handling, wallpaper and notifications as one package) +
**greetd** with the **tuigreet** greeter. Theme is Catppuccin Mocha
throughout.

The previous hand-written Quickshell bar (plus hyprlock/hypridle/hyprpaper/
fuzzel/cliphist) is preserved on the `quickshell` branch, where it continues
to be developed separately — `master` runs Noctalia for a ready-to-use setup
on both machines in the meantime.

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
│                          # by base/hooks/noctalia-shell.sh)
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
make deps    # git submodules + git-lfs (install + pull wallpapers) + install paru if missing
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
  in `hyprland.lua` since the external monitor setup changes by desk; run
  `hyprctl monitors` after docking and adjust the commented-out
  `hl.monitor({...})` calls. `D7JW8FS` ships a real 2-monitor layout as a
  starting point — update the connector names to match `hyprctl monitors` on
  that machine.
- `hyprland.conf` was migrated to `hyprland.lua` — Hyprland deprecated the
  classic key/value `.conf` syntax (hyprlang) in favor of Lua as of 0.55, and
  will drop `.conf` support entirely in 0.57. The `hl.*` API used here (
  `hl.config({...})`, `hl.monitor({...})`, `hl.bind(...)`,
  `hl.on("hyprland.start", ...)`, `hl.dsp.*` dispatchers) was checked against
  the [official wiki](https://wiki.hypr.land/Configuring/Start/) and
  [Hyprland's own example config](https://github.com/hyprwm/Hyprland/blob/main/example/hyprland.lua),
  and every `.lua` file in this repo was syntax-checked with a real Lua
  parser (not just eyeballed) before being committed — but none of it has run
  against a live Hyprland session from this sandbox, so treat the first
  reload/reboot after pulling this as the real test. One renamed option to
  know about: touchpad `tap-to-click` became `tap_to_click` (Lua table keys
  can't contain hyphens).
- Hyprland 0.55 also removed the global `dwindle` `pseudotile` option —
  pseudo tiling is now per-window only, via the `pseudo` dispatcher or a
  window rule, so `hyprland.lua` doesn't set it globally anymore.
- **Noctalia** (`noctalia-shell` AUR package, built on Quickshell) is the whole
  desktop shell now — one process providing the bar, app launcher, control
  center, lock screen, idle behavior, wallpaper, notifications, clipboard
  history and OSDs, instead of the separate
  hyprlock/hypridle/hyprpaper/fuzzel/cliphist/Quickshell-bar combo used
  before. It replaces all of those packages and their configs; none of them
  are in `base/packages` or `base/config` anymore.
  - Started from `hyprland.lua`'s `hyprland.start` autostart hook via
    `hl.exec_cmd("noctalia")`.
  - Controlled at runtime through `noctalia msg <command>` IPC — see the
    keybinds in `hyprland.lua` (`$mod+D` launcher, `$mod+S` control center,
    `$mod+L` lock). Run `noctalia msg --help` for the full command list.
  - `base/hooks/noctalia-shell.sh` (previously `hyprpaper.sh`) still seeds
    `~/.wallpapers/` from the vendored `wallpapers/` directory on first run,
    so Noctalia's own wallpaper picker has something to point at — first-run
    theme/wallpaper/idle-timeout settings are configured through Noctalia's
    own settings UI (`noctalia msg settings-open`) rather than a hand-written
    dotfile, since it manages its own `~/.config/noctalia/settings.toml`.
    `make deps` installs `git-lfs` and runs `git lfs pull` before this hook
    ever runs, so the copied wallpapers are real PNGs rather than unresolved
    LFS pointer stubs; the hook also re-runs `git lfs pull` itself as a
    fallback if it's ever invoked without `make deps` having run first.
  - A `hl.window_rule`/`hl.layer_rule` pair in `hyprland.lua` (float + size
    for the settings window, blur + no-anim for the bar/panels/OSD/dock
    layers) mirrors Noctalia's own recommended Hyprland config.
  - Noctalia also ships an optional greeter (`noctalia-greeter-session`) that
    could replace `greetd`+`tuigreet` — not adopted here, greetd/tuigreet is
    unchanged.
  - The previous hand-written Quickshell bar (`Bar.qml`, `Workspaces.qml`,
    etc.) is preserved on the `quickshell` branch, where that approach
    continues to be developed independently of this stack.
- `greetd` runs `tuigreet` (official `extra` package, no AUR needed), which
  launches `start-hyprland` (the crash-recovery/safe-mode wrapper Hyprland
  ships since 0.53+, not the bare `Hyprland` binary) — see
  `base/config/etc/greetd/config.toml`.
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
