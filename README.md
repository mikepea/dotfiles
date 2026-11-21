# dotfiles

Managed with [chezmoi](https://chezmoi.io).

## New machine

CachyOS/Arch, Ubuntu and macOS. First get `make` and `git`
(Ubuntu: `sudo apt install -y make git`; macOS: `xcode-select --install`), then:

    git clone https://github.com/mikepea/dotfiles.git ~/git/mikepea/dotfiles
    cd ~/git/mikepea/dotfiles
    make all        # install tools, point chezmoi at this checkout, apply

`make` on its own lists the individual steps (`install`, `init`, `diff`,
`apply`, `doctor`, and the opt-in Arch-only `desktop`).

## Daily use

    chezmoi edit ~/.zshrc     # edit the source, not the target
    chezmoi diff              # preview what would change in $HOME
    chezmoi apply             # write changes to $HOME
    chezmoi add ~/.foorc      # start managing a new file
    chezmoi re-add            # pull in edits made directly in $HOME
    chezmoi cd                # shell into the source repo, then git push

CLI tools such as kubectl and talosctl are pinned in `dot_tool-versions`
(`~/.tool-versions`) and installed by asdf. To bump one, edit the version
there and `chezmoi apply`: `run_onchange_after_asdf-install.sh.tmpl` re-runs
whenever that file changes, adding any missing plugin and installing.

See `.chezmoiignore` for what is deliberately not tracked.
