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

Desktop stack: **Hyprland** (Wayland compositor) + **Quickshell** (bar/widgets,
written from scratch — no pre-built shell) + **hyprlock**/**hypridle**
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
- `quickshell` is the official `extra` package (no AUR needed) — there's
  deliberately no pre-built shell (Caelestia/DMS/Waybar+Mako+Walker/etc.) on
  top of it. `base/config/home/{{USER}}/.config/quickshell/` is a small
  hand-written bar, not a framework:
  - `shell.qml` — root; uses `Variants`/`Quickshell.screens` to spawn one
    `Bar` per monitor.
  - `Bar.qml` — the `PanelWindow` (top strip, 34px): distro logo + workspaces
    + active window on the left, clock centered, tray/media/notifications/
    clipboard/bluetooth/network/volume/battery/power on the right.
    Catppuccin Mocha colors via the `Colors.qml` singleton (`pragma
    Singleton`, no `qmldir` needed — Quickshell auto-registers
    uppercase-named sibling `.qml` files as types in the config directory).
    Type names are chosen to avoid shadowing built-in singletons (e.g.
    `BatteryWidget.qml` not `Battery.qml`, `NetworkWidget.qml` not
    `Network.qml`) — QML doesn't allow redeclaring an existing type/property
    name.
  - `Workspaces.qml` / `ActiveWindow.qml` — `Quickshell.Hyprland` IPC and the
    compositor-agnostic `Quickshell.Wayland.ToplevelManager`.
  - `Media.qml` — `Quickshell.Services.Mpris`; shows the first playing (or
    otherwise first available) player, click to play/pause.
  - `Notifications.qml` — `Quickshell.Services.Notifications`; this repo's
    shell *is* the notification daemon (nothing else provides
    `org.freedesktop.Notifications`). Currently just an unread-count bell —
    clicking dismisses everything tracked. No popup/history view yet, that's
    a bigger feature to add later.
  - `Clipboard.qml` — runs `cliphist list | fuzzel --dmenu | cliphist decode
    | wl-copy` on click (cliphist itself is already fed by the
    `wl-paste --watch cliphist store` autostart line in `hyprland.lua`).
  - `BluetoothWidget.qml` — `Quickshell.Bluetooth` (BlueZ); needs
    `bluez`/`bluez-utils` (in `base/packages`, service enabled by
    `base/hooks/bluez.sh`).
  - `NetworkWidget.qml` — `Quickshell.Networking` (NetworkManager); shows the
    connected network's name, with a wifi/wired/none icon.
  - `Volume.qml` / `BatteryWidget.qml` — `Quickshell.Services.Pipewire` /
    `.UPower`; needs `pipewire`/`wireplumber`/`upower` (in `base/packages`,
    enabled by `base/hooks/pipewire.sh`). `BatteryWidget` hides itself
    (`isLaptopBattery` check) on `D7JW8FS`, which has no battery.
  - `TrayWidget.qml` — `Quickshell.Services.SystemTray`.
  - `PowerMenu.qml` / `PowerMenuButton.qml` — a `PopupWindow` with
    Lock/Log out/Reboot/Shutdown, opened from the ⏻ button. Lock runs
    `hyprlock` (in `base/packages`); log out uses `Hyprland.dispatch("exit")`.
  - `assets/arch-logo.svg` — Arch Linux's own "Crystal" icon, used as-is in
    the bar's top-left corner.
  - Icons are plain emoji, not Nerd Font glyphs — renders correctly with any
    font, no icon-codepoint guessing required.
  `hyprland.lua`'s autostart block runs `qs`, which loads
  `~/.config/quickshell/shell.qml` by default (no `-c`/`-p` flags needed).
  `walker`/`mako`/`waybar` were tried and reverted — the app launcher is
  `fuzzel` again (bound to `$mod+D`), not Walker.
  This is a hand-rolled starting point, not a finished product — extend it
  as you go; the Quickshell API calls above were checked against the
  official docs but not run against a live compositor from this sandbox, so
  treat first boot as the real test. See
  [quickshell.org/docs](https://quickshell.org/docs/) for writing more.
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
