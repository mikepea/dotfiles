
install:
	install -m 0640 bash/bash_profile ~/.bash_profile
	install -m 0640 git/gitconfig ~/.gitconfig
	install -m 0640 vim/vimrc ~/.vimrc
	mkdir  -p ~/.vim
	rsync -r vim/vim/ ~/.vim/
	install -m 0640 tmux/tmux.conf ~/.tmux.conf
	install -m 0640 readline/inputrc ~/.inputrc
	mkdir -p ~/bin

diff:
	diff -p ~/.bash_profile bash/bash_profile
	diff -p ~/.gitconfig git/gitconfig
	diff -p ~/.vimrc vim/vimrc 
	diff -p ~/.tmux.conf tmux/tmux.conf 

.PHONY: install
