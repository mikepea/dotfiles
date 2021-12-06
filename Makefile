
install:
	install -m 0640 bash/bash_profile ~/.bash_profile
	install -m 0640 git/gitconfig ~/.gitconfig
	install -m 0640 vim/vimrc ~/.vimrc
	install -m 0640 zsh/zshrc ~/.zshrc
	mkdir  -p ~/.vim
	rsync -r vim/vim/ ~/.vim/
	install -m 0640 tmux/tmux.conf ~/.tmux.conf
	install -m 0640 readline/inputrc ~/.inputrc
	mkdir -p ~/bin

diff:
	diff -p ~/.bash_profile bash/bash_profile || true
	diff -p ~/.zshrc zsh/zshrc || true
	diff -p ~/.gitconfig git/gitconfig || true
	diff -p ~/.vimrc vim/vimrc || true
	diff -p ~/.tmux.conf tmux/tmux.conf || true

.PHONY: install
