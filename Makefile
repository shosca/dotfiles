PWD=$(shell pwd)

install:
	ln -sf $(PWD)/.ackrc ~/.ackrc
	ln -sf $(PWD)/.gitconfig ~/.gitconfig
	ln -sf $(PWD)/.zshrc ~/.zshrc
	ln -sf $(PWD)/.inputrc ~/.inputrc
	ln -sf $(PWD)/.vimrc.local ~/.vimrc.local
	ln -sf $(PWD)/.vimrc.before.local ~/.vimrc.before.local
	ln -sf $(PWD)/.vimrc.bundles.local ~/.vimrc.bundles.local

