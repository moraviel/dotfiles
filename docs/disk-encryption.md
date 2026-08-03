# Disk encryption (LUKS2) for a fresh Arch install

Both machines need full-disk encryption. It has to be set up again during the Arch install, 
before this dotfiles repo is even cloned (`make` only configures a system
that already exists; it cannot encrypt a live root filesystem after the fact 
without a wipe/reinstall anyway).

Layout used below: **LUKS2 + a single root partition**, unencrypted ESP,
**systemd-boot**.

## 1. Partition the disk

Boot the Arch ISO, then (replace `/dev/sdX` with your disk, e.g. `/dev/nvme0n1`):

```sh
cfdisk /dev/sdX
```

Create two partitions:
- `sdX1` — ~1 GiB, type **EFI System** — this becomes `/boot`, stays unencrypted
- `sdX2` — rest of the disk, type **Linux filesystem** — this becomes the LUKS container

## 2. Create the LUKS container

```sh
cryptsetup luksFormat --type luks2 /dev/sdX2
cryptsetup open /dev/sdX2 cryptroot
mkfs.ext4 /dev/mapper/cryptroot
mkfs.fat -F32 /dev/sdX1
```

(Use `mkfs.btrfs` instead of `mkfs.ext4` if you want btrfs — the rest of
this guide doesn't change either way.)

## 3. Mount and install

```sh
mount /dev/mapper/cryptroot /mnt
mkdir -p /mnt/boot
mount /dev/sdX1 /mnt/boot

pacstrap -K /mnt base linux linux-firmware cryptsetup sudo
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt
```

From here on you're inside the chroot. Set locale/timezone/hostname as usual
(`/etc/hostname` must be `UXL-4JSYDX3` or `D7JW8FS` to match this repo's
layers), then continue below.

## 4. mkinitcpio: add the `encrypt` hook

Edit `/etc/mkinitcpio.conf` and make sure `encrypt` appears **after** `block`
and **before** `filesystems`:

```
HOOKS=(base udev autodetect modconf kms keyboard keymap consolefont block encrypt filesystems fsck)
```

If you also want the Plymouth splash on the unlock prompt, put `plymouth`
right after `udev` and keep `encrypt` before `filesystems`:

```
HOOKS=(base udev plymouth autodetect modconf kms keyboard keymap consolefont block encrypt filesystems fsck)
```

`base/hooks/plymouth.sh` and `UXL-4JSYDX3/hooks/nvidia-open.sh` in this repo
only *append* to whatever `HOOKS=(...)`/`MODULES=(...)` already exist — they
won't reorder `encrypt` for you, so get this line right by hand first.

Regenerate the initramfs:

```sh
mkinitcpio -P
```

## 5. Bootloader: systemd-boot

```sh
bootctl install
```

Get the LUKS UUID of the **encrypted partition** (`/dev/sdX2`, not the mapper):

```sh
blkid -s UUID -o value /dev/sdX2
```

Create `/boot/loader/entries/arch.conf`:

```
title   Arch Linux
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options cryptdevice=UUID=<uuid-from-above>:cryptroot root=/dev/mapper/cryptroot rw
```

And `/boot/loader/loader.conf`:

```
default arch.conf
timeout 3
console-mode max
editor no
```

## 6. Continue with the normal install

Set the root password, create your user, install a network manager if you
need one before reboot, then `exit`, unmount, and `reboot`.

Once you're booted into the fresh install and logged in as your user, clone
this repo and run `make` as documented in the main [README](../README.md).

## Changing the LUKS passphrase later

```sh
sudo cryptsetup luksChangeKey /dev/sdX2
```

## Notes

- `cryptsetup` is in `base/packages` so `make pkgs` keeps it installed, but
  the actual LUKS setup above has to happen at install time — it's not
  something `make` runs for you.
- If you add a swap partition/file later, encrypt it too (either as its own
  LUKS volume, or a swapfile inside the already-encrypted root — the latter
  is simpler and is what's assumed above since this repo doesn't set up a
  separate swap partition).
