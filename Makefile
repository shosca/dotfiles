PWD=$(shell pwd)
BASE16_SHELL=~/.config/base16-shell
SPF13=~/.spf13-vim-3
SPF13FILES= \
			.vimrc \
			.vimrc.before \
			.vimrc.bundles

SPF13LOCALFILES= \
			.vimrc.local \
			.vimrc.before.local \
			.vimrc.bundles.local

OHMYZSH=~/.oh-my-zsh
OHMYZSHFILES=\
			.zshrc

SYMLINKS= \
	.ackrc \
	.pdbrc \
	.gitconfig \
	.hgrc \
	.psqlrc \
	.rspec \
	.rvmrc \
	.inputrc \
	.jshintrc \
	.ctags \
	.yaourtrc

CLEANFILES= \
			.vim \
			.vimbackup \
			.viminfo \
			.vimswap \
			.vimundo \
			.vimviews \
			$(OHMYZSH) \
			$(OHMYZSHFILES) \
			$(SPF13) \
			$(SPF13FILES) \
			$(SPF13LOCALFILES) \
			$(BASE16_SHELL)

all: ohmyzsh spf13 symlinks

base16:
	if [[ ! -d $(BASE16_SHELL) ]]; then \
		git clone https://github.com/chriskempson/base16-shell.git $(BASE16_SHELL) ; \
	else \
		cd $(BASE16_SHELL) && git pull ; \
	fi

ohmyzsh:
	for f in $(OHMYZSHFILES); do \
		ln -sf $(PWD)/$$f ~/$$f ; \
	done
	if [[ ! -e $(OHMYZSH) ]]; then \
		git clone https://github.com/robbyrussell/oh-my-zsh.git $(OHMYZSH) ; \
		ln -sf $(PWD)/gentoo2.zsh-theme $(OHMYZSH)/themes/gentoo2.zsh-theme ; \
	else \
		cd $(OHMYZSH) && git pull ; \
	fi

vim:
	if [[ ! -d ~/.vim/bundle/neobundle.vim ]] ; then \
		git clone https://github.com/Shougo/neobundle.vim.git ~/.vim/bundle/neocomplete.vim
	fi
	ln -sf $(PWD)/.vimrc ~/.vimrc

spf13:
	for f in $(SPF13LOCALFILES); do \
		ln -sf $(PWD)/$$f ~/$$f ; \
	done
	if [[ -e $(SPF13) ]]; then \
		cd ~/.spf13-vim-3 && git pull ; \
		vim "+BundleInstall!" "+BundleClean" "+qall" ; \
	else \
		git clone -b 3.0 https://github.com/spf13/spf13-vim.git ~/$(SPF13) ; \
		mkdir -p ~/.vim/bundle ; \
		git clone -b master https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle ; \
		for f in $(SPF13FILES) ; do \
			ln -sf $(SPF13)/$$f ~/$$f ; \
		done ; \
		vim -u "$(SPF13)/.vimrc.bundles.default" "+BundleInstall!" "+BundleClean" "+qall" ; \
	fi ; \
	python2 ~/.vim/bundle/YouCompleteMe/install.py

symlinks:
	for f in $(SYMLINKS); do \
		ln -sf $(PWD)/$$f ~/$$f ; \
	done

clean:
	for f in $(SYMLINKS) $(OHMYZSH) $(SPF13) $(CLEANFILES) ; do \
		rm -rf ~/$$f ; \
	done
