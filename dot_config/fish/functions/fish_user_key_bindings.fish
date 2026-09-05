function fish_user_key_bindings --description 'Extra bindings layered on top of vi mode'
    # Keep the three emacs keys that are pure muscle memory, in insert mode
    # only -- normal mode keeps their vi meanings.
    #
    # Note ctrl-a is also the tmux prefix, so inside tmux you reach this with
    # the escape hatch from tmux.conf: C-a a.
    bind -M insert ctrl-a beginning-of-line
    bind -M insert ctrl-e end-of-line
    bind -M insert ctrl-r history-pager
end
