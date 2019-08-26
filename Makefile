
install:
	install -m 0640 bash/bash_profile ~/.bash_profile
	install -m 0640 git/gitconfig ~/.gitconfig
	install -m 0640 vim/vimrc ~/.vimrc
	mkdir  -p ~/.vim
	rsync -r vim/vim/ ~/.vim/
	install -m 0640 tmux/tmux.conf ~/.tmux.conf
	install -m 0640 readline/inputrc ~/.inputrc
	mkdir -p ~/bin

.PHONY: install