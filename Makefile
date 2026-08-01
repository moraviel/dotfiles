HOST := $(shell cat /etc/hostname)

.PHONY: all deps pkgs aur cfg hooks

all: deps pkgs aur cfg hooks

deps:
	@echo "--- Initializing submodules ---"
	@git submodule update --init --recursive
	@if ! command -v paru >/dev/null 2>&1; then \
		echo "--- Installing paru from AUR ---"; \
		sudo pacman -S --needed --noconfirm base-devel git; \
		tmpdir=$$(mktemp -d); \
		git clone https://aur.archlinux.org/paru.git "$$tmpdir/paru"; \
		(cd "$$tmpdir/paru" && makepkg -si --noconfirm); \
		rm -rf "$$tmpdir"; \
	else \
		echo "--- paru already installed ---"; \
	fi

pkgs:
	@echo "--- Installing pacman packages for $(HOST) ---"
	@pkgs=$$(cat base/packages $(HOST)/packages 2>/dev/null | sed '/^\s*#/d;/^\s*$$/d' | sort -u); \
	if echo "$$pkgs" | grep -qE '^(steam|lutris)$$' && ! grep -q '^\[multilib\]' /etc/pacman.conf; then \
		echo "--- Enabling [multilib] repo for $$pkgs ---"; \
		sudo sed -i "/^#\[multilib\]/,/^#Include/"' s/^#//' /etc/pacman.conf; \
		sudo pacman -Sy; \
	fi; \
	sudo pacman -S --needed $$pkgs

aur:
	@echo "--- Installing AUR packages for $(HOST) ---"
	@pkgs=$$(cat base/aur-packages $(HOST)/aur-packages 2>/dev/null | sed '/^\s*#/d;/^\s*$$/d' | sort -u); \
	paru -S --needed $$pkgs

cfg:
	@echo "--- Deploying config for $(HOST) ---"
	@HOST=$(HOST) bash scripts/deploy-config.sh

hooks:
	@echo "--- Running hooks for $(HOST) ---"
	@HOST=$(HOST) bash scripts/run-hooks.sh
