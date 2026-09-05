#!/bin/sh
# Bootstrap tmux plugin manager so `chezmoi init --apply` needs no follow-up.
# chezmoi re-runs this only if its contents change.
set -eu

TPM_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/tmux/plugins/tpm"

if [ -d "$TPM_DIR" ]; then
	echo "tpm already present at $TPM_DIR"
	exit 0
fi

if ! command -v git >/dev/null 2>&1; then
	echo "tpm: git not found, skipping install" >&2
	exit 0
fi
if ! command -v tmux >/dev/null 2>&1; then
	echo "tpm: tmux not found, skipping install" >&2
	exit 0
fi

echo "tpm: cloning into $TPM_DIR"
git clone --depth 1 https://github.com/tmux-plugins/tpm "$TPM_DIR"

# Best-effort: don't fail `chezmoi apply` if plugin install has trouble.
"$TPM_DIR/bin/install_plugins" || echo "tpm: install_plugins failed; run 'prefix I' inside tmux" >&2
