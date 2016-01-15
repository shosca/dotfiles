PWD=$(shell pwd)
SPF13=~/.spf13-vim-3
OHMYZSH=~/.oh-my-zsh

all: ohmyzsh spf13

ohmyzsh: symlinks
	if [[ ! -e $(OHMYZSH) ]]; then \
		git clone https://github.com/robbyrussell/oh-my-zsh.git $(OHMYZSH) ; \
		ln -sf $(PWD)/gentoo2.zsh-theme $(OHMYZSH)/themes/gentoo2.zsh-theme ; \
	fi

spf13: symlinks
	if [[ -e $(SPF13) ]]; then \
		cd ~/.spf13-vim-3 && git pull ; \
		vim "+set nomore" "+BundleInstall!" "+BundleClean" "+qall" ; \
	else \
		git clone -b 3.0 https://github.com/spf13/spf13-vim.git $(SPF13) ; \
		git clone -b master https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle ; \
		ln -sf $(SPF13)/.vimrc         ~/.vimrc ; \
		ln -sf $(SPF13)/.vimrc.bundles ~/.vimrc.bundles ; \
		ln -sf $(SPF13)/.vimrc.before  ~/.vimrc.before ; \
		ln -sf $(SPF13)/.vim           ~/.vim ; \
		vim -u "$(SPF13)/.vimrc.bundles.default" "+set nomore" "+BundleInstall!" "+BundleClean" "+qall" ; \
	fi ; \
	python2 ~/.vim/bundle/YouCompleteMe/install.py

symlinks:
	ln -sf $(PWD)/.ackrc ~/.ackrc
	ln -sf $(PWD)/.pdbrc ~/.pdbrc 
	ln -sf $(PWD)/.gitconfig ~/.gitconfig
	ln -sf $(PWD)/.hgrc ~/.hgrc
	ln -sf $(PWD)/.psqlrc ~/.psqlrc
	ln -sf $(PWD)/.rspec ~/.rspec
	ln -sf $(PWD)/.rvmrc ~/.rvmrc
	ln -sf $(PWD)/.zshrc ~/.zshrc
	ln -sf $(PWD)/.inputrc ~/.inputrc
	ln -sf $(PWD)/.jshintrc~/.jshintrc
	ln -sf $(PWD)/.ctags ~/.ctags
	ln -sf $(PWD)/.vimrc.local ~/.vimrc.local
	ln -sf $(PWD)/.vimrc.before.local ~/.vimrc.before.local
	ln -sf $(PWD)/.vimrc.bundles.local ~/.vimrc.bundles.local

