# dotfiles

Managed with [chezmoi](https://chezmoi.io).

## New machine

    sudo pacman -S chezmoi          # or: sh -c "$(curl -fsLS get.chezmoi.io)"
    chezmoi init --apply <this-repo-url>

## Daily use

    chezmoi edit ~/.zshrc     # edit the source, not the target
    chezmoi diff              # preview what would change in $HOME
    chezmoi apply             # write changes to $HOME
    chezmoi add ~/.foorc      # start managing a new file
    chezmoi re-add            # pull in edits made directly in $HOME
    chezmoi cd                # shell into the source repo, then git push

See `.chezmoiignore` for what is deliberately not tracked.
