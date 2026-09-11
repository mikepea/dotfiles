# Vi key bindings. This has to be set *before* sourcing the CachyOS config:
# that file checks $fish_key_bindings to decide whether to bind its !/$
# history helpers into insert mode, and it only gets one look.
set -g fish_key_bindings fish_vi_key_bindings

source /usr/share/cachyos-fish-config/cachyos-config.fish

# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end

# --- git ----------------------------------------------------------------
# Ported from the zsh/bash aliases in the old dotfiles repo. These are
# abbreviations rather than aliases: fish expands them inline as you type,
# so the real command lands in your history.
abbr -a gco  git checkout
abbr -a gcob git checkout -b
abbr -a gb   git branch
abbr -a gs   git status
abbr -a gd   git diff
# gcom is a function (see functions/gcom.fish) since it has to work out
# what the default branch is called.

# --- vi mode ------------------------------------------------------------
# Cursor shape follows the mode, so you can see where you are.
set -g fish_cursor_default     block
set -g fish_cursor_insert      line
set -g fish_cursor_replace_one underscore
set -g fish_cursor_visual      block
# Insert-mode escape hatches live in functions/fish_user_key_bindings.fish.
# conf.d (autopair) re-initialises key bindings after fish's own call to
# fish_user_key_bindings, which drops ours. config.fish is sourced after
# conf.d, so re-apply them here. bind is idempotent, so the double call
# fish may still make is harmless.
fish_user_key_bindings

if test -z $ASDF_DATA_DIR
	set _asdf_shims "$HOME/.asdf/shims"
else
	set _asdf_shims "$ASDF_DATA_DIR/shims"
end

if not contains $_asdf_shims $PATH
	set -gx --prepend PATH $_asdf_shims
end
set --erase _asdf_shims
