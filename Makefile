# Prepare a fresh machine for these dotfiles, then apply them with chezmoi.
#
# Supported: CachyOS (and other Arch derivatives), Ubuntu (and derivatives),
# macOS. On a fresh box you need make and git before you can get this far:
#
#   Ubuntu:  sudo apt install -y make git
#   macOS:   xcode-select --install       (provides both)
#   CachyOS: already there
#
# Then:
#
#   git clone https://github.com/mikepea/dotfiles.git ~/git/mikepea/dotfiles
#   cd ~/git/mikepea/dotfiles
#   make all
#
# Written for the GNU make 3.81 that macOS ships: no .ONESHELL, no $(file).

SHELL := /bin/sh

# Each step needs the one before it (packages, then asdf via go, then apply),
# so never run them side by side, even under `make -j`.
.NOTPARALLEL:

# Tools installed part-way through a run (Homebrew, chezmoi and nvim in
# ~/.local/bin, asdf in ~/go/bin) aren't on the caller's PATH yet, so put them
# there for every recipe.
export PATH := $(HOME)/.local/bin:$(HOME)/go/bin:/opt/homebrew/bin:/usr/local/bin:$(PATH)

# --------------------------------------------------------------- detect OS --
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
  OS := macos
else
  OS_ID   := $(shell . /etc/os-release 2>/dev/null && echo "$$ID")
  OS_LIKE := $(shell . /etc/os-release 2>/dev/null && echo "$$ID_LIKE")
  ifeq ($(OS_ID),cachyos)
    OS := arch
  else ifeq ($(OS_ID),arch)
    OS := arch
  else ifneq ($(filter arch,$(OS_LIKE)),)
    OS := arch
  else ifeq ($(OS_ID),ubuntu)
    OS := ubuntu
  else ifneq ($(filter ubuntu debian,$(OS_LIKE)),)
    OS := ubuntu
  else
    OS := unsupported
  endif
endif

# ---------------------------------------------------------------- packages --
# What the dotfiles expect to find: chezmoi to apply them, git and tmux for
# the tpm bootstrap script, gh so dot_gitconfig.tmpl wires up its credential
# helper (it checks lookPath "gh" at apply time, so gh must come first).
ARCH_PKGS   := chezmoi git tmux neovim fish zsh micro github-cli go \
               cachyos-fish-config cachyos-zsh-config
UBUNTU_PKGS := git tmux fish zsh micro gh golang-go curl ca-certificates
BREW_PKGS   := chezmoi git tmux neovim fish micro gh go

# asdf is built with `go install`, so it lands where go puts binaries ($GOBIN,
# else $GOPATH/bin, else ~/go/bin), which the shell configs put on PATH. This
# release needs Go >= 1.26.3; GOTOOLCHAIN=auto lets an older go (Ubuntu's apt
# one, which must still be >= 1.21) download that toolchain itself.
ASDF_VERSION := v0.20.2

# Opt-in desktop session for `make desktop` (Arch only): labwc + kanshi, the
# older openbox + tint2 session, and gamescope/steam for ~/.local/bin/bigpicture.
DESKTOP_PKGS := labwc kanshi swaybg dunst openbox tint2 feh xsettingsd \
                polkit-gnome gamescope steam

CHEZMOI_CONFIG := $(HOME)/.config/chezmoi/chezmoi.toml

.DEFAULT_GOAL := help

.PHONY: help all install init apply diff doctor desktop check-os \
        install-arch install-ubuntu install-macos \
        ubuntu-chezmoi ubuntu-neovim homebrew oh-my-zsh asdf

help:
	@echo "Detected OS: $(OS)"
	@echo
	@echo "  make all      install, init, then apply (fresh machine)"
	@echo "  make install  install chezmoi and the tools the dotfiles use"
	@echo "  make asdf     go install asdf $(ASDF_VERSION) (part of install)"
	@echo "  make init     point chezmoi at this checkout ($(CURDIR))"
	@echo "  make diff     show what apply would change in \$$HOME"
	@echo "  make apply    write the dotfiles into \$$HOME"
	@echo "  make doctor   show tool versions and run chezmoi doctor"
	@echo "  make desktop  Arch only: labwc/openbox session and gamescope"

all: install init apply

check-os:
	@if [ "$(OS)" = unsupported ]; then \
	  echo "Unsupported OS ($(UNAME_S) $(OS_ID)). Expected CachyOS/Arch, Ubuntu or macOS." >&2; \
	  exit 1; \
	fi

install: check-os install-$(OS) asdf

asdf:
	GOTOOLCHAIN=auto go install github.com/asdf-vm/asdf/cmd/asdf@$(ASDF_VERSION)
	@echo "asdf: $$(command -v asdf) ($$(asdf --version))"

# -------------------------------------------------------------------- Arch --
install-arch:
	sudo pacman -S --needed --noconfirm $(ARCH_PKGS)

desktop: check-os
	@if [ "$(OS)" != arch ]; then \
	  echo "make desktop is for CachyOS/Arch only." >&2; exit 1; \
	fi
	sudo pacman -S --needed --noconfirm $(DESKTOP_PKGS)

# ------------------------------------------------------------------ Ubuntu --
install-ubuntu:
	sudo apt-get update
	sudo apt-get install -y $(UBUNTU_PKGS)
	$(MAKE) ubuntu-chezmoi ubuntu-neovim

# Not packaged in apt. The upstream installer drops a single static binary.
ubuntu-chezmoi:
	@if command -v chezmoi >/dev/null 2>&1; then \
	  echo "chezmoi already installed: $$(command -v chezmoi)"; \
	else \
	  mkdir -p "$$HOME/.local/bin" && \
	  sh -c "$$(curl -fsLS get.chezmoi.io)" -- -b "$$HOME/.local/bin"; \
	fi

# init.lua needs nvim >= 0.11; apt has 0.9 on 24.04. Use the upstream release
# unless a new enough nvim is already on PATH.
ubuntu-neovim:
	@if command -v nvim >/dev/null 2>&1 && \
	    nvim --headless -c 'exe has("nvim-0.11") ? "qa!" : "cq"' >/dev/null 2>&1; then \
	  echo "neovim >= 0.11 already installed: $$(command -v nvim)"; \
	else \
	  set -e; \
	  case "$$(uname -m)" in \
	    x86_64)        arch=x86_64 ;; \
	    aarch64|arm64) arch=arm64 ;; \
	    *) echo "no neovim release for $$(uname -m)" >&2; exit 1 ;; \
	  esac; \
	  mkdir -p "$$HOME/.local/opt" "$$HOME/.local/bin"; \
	  rm -rf "$$HOME/.local/opt/nvim" "$$HOME/.local/opt/nvim-linux-$$arch"; \
	  curl -fsSL "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-$$arch.tar.gz" \
	    | tar -xz -C "$$HOME/.local/opt"; \
	  mv "$$HOME/.local/opt/nvim-linux-$$arch" "$$HOME/.local/opt/nvim"; \
	  ln -sf "$$HOME/.local/opt/nvim/bin/nvim" "$$HOME/.local/bin/nvim"; \
	  echo "neovim installed to ~/.local/opt/nvim"; \
	fi

# ------------------------------------------------------------------- macOS --
install-macos: homebrew
	brew install $(BREW_PKGS)
	$(MAKE) oh-my-zsh

homebrew:
	@if command -v brew >/dev/null 2>&1; then \
	  echo "Homebrew already installed: $$(command -v brew)"; \
	else \
	  NONINTERACTIVE=1 /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
	fi

# The darwin branch of dot_zshrc.tmpl sources ~/.oh-my-zsh/oh-my-zsh.sh.
# KEEP_ZSHRC stops the installer replacing ~/.zshrc; chezmoi owns that file.
oh-my-zsh:
	@if [ -d "$$HOME/.oh-my-zsh" ]; then \
	  echo "oh-my-zsh already installed"; \
	else \
	  RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \
	    "$$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"; \
	fi

# ----------------------------------------------------------------- chezmoi --
# Make this checkout chezmoi's source directory, so plain `chezmoi diff`,
# `chezmoi apply` and `chezmoi cd` work afterwards. Won't touch an existing
# config; it only warns if that config points somewhere else.
init:
	@set -e; \
	dir="$$HOME/.config/chezmoi"; \
	existing=$$(ls "$$dir"/chezmoi.* 2>/dev/null | head -n 1); \
	if [ -z "$$existing" ]; then \
	  mkdir -p "$$dir"; \
	  printf 'sourceDir = "%s"\n' "$(CURDIR)" > "$(CHEZMOI_CONFIG)"; \
	  echo "wrote $(CHEZMOI_CONFIG): sourceDir = $(CURDIR)"; \
	elif [ "$$(chezmoi source-path)" = "$(CURDIR)" ]; then \
	  echo "chezmoi already uses $(CURDIR)"; \
	else \
	  echo "warning: $$existing exists and its source is $$(chezmoi source-path)," >&2; \
	  echo "         not $(CURDIR). Set sourceDir there, or apply with --source." >&2; \
	fi

diff:
	chezmoi --source "$(CURDIR)" diff

# chezmoi asks before overwriting a file that differs from what it last wrote,
# so this is safe to run over an existing $HOME. Run `make diff` first to see.
apply:
	chezmoi --source "$(CURDIR)" apply --verbose

doctor:
	@echo "OS: $(OS)"
	@for t in chezmoi git tmux nvim fish zsh micro gh go asdf; do \
	  if command -v $$t >/dev/null 2>&1; then \
	    case $$t in tmux) v=-V ;; go) v=version ;; *) v=--version ;; esac; \
	    printf '  %-8s %s\n' "$$t" "$$($$t $$v 2>&1 | head -n 1)"; \
	  else \
	    printf '  %-8s MISSING\n' "$$t"; \
	  fi; \
	done
	-chezmoi --source "$(CURDIR)" doctor
