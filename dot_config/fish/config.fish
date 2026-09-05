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
