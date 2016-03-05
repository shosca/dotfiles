PWD=$(shell pwd)
BASE16_SHELL=~/.config/base16-shell

OHMYZSH=~/.oh-my-zsh
OHMYZSHFILES=\
			.zshrc

SYMLINKS= \
	.ackrc \
	.ctags \
	.gitconfig \
	.hgrc \
	.inputrc \
	.jshintrc \
	.pdbrc \
	.psqlrc \
	.rspec \
	.rvmrc \
	.tmux.conf \
	.yaourtrc

CLEANFILES= \
			.vim \
			.vimrc \
			.vimbackup \
			.viminfo \
			.vimswap \
			.vimundo \
			.vimviews \
			$(OHMYZSH) \
			$(OHMYZSHFILES) \
			$(BASE16_SHELL)

install: ohmyzsh symlinks base16 ## Installs dotfiles

ohmyzsh: ## Sets up oh-my-zsh
	for f in $(OHMYZSHFILES); do \
		ln -sf $(PWD)/$$f ~/$$f ; \
	done
	if [[ ! -e $(OHMYZSH) ]]; then \
		git clone https://github.com/robbyrussell/oh-my-zsh.git $(OHMYZSH) ; \
	else \
		cd $(OHMYZSH) && git pull ; \
	fi

neobundle: ## Sets vim with neobundle
	mkdir -p ~/.vim/bundle ; \
	mkdir -p ~/.config/; \
	ln -sf ~/.vim ~/.config/nvim ; \
	ln -sf $(PWD)/.vimrc ~/.vim/vimrc ; \
	ln -sf $(PWD)/.vimrc ~/.config/nvim/init.vim; \
	if [[ ! -d ~/.vim/bundle/neobundle.vim ]] ; then \
		git clone https://github.com/Shougo/neobundle.vim.git ~/.vim/bundle/neobundle.vim ; \
	fi ; \
	if [[ ! -d ~/.vim/bundle/vimproc.vim ]] ; then \
		git clone https://github.com/Shougo/vimproc.vim.git ~/.vim/bundle/vimproc.vim ; \
		make -C ~/.vim/bundle/vimproc.vim/ && \
		vim -N -u ~/.vim/vimrc -c "try | NeoBundleInstall | finally | qall! | endtry" \
			-U NONE -i NONE -V1 -e -s ; \
	else \
		vim -N -u ~/.vim/vimrc -c "try | NeoBundleUpdate | finally | qall! | endtry" \
			-U NONE -i NONE -V1 -e -s ; \
	fi ; \

symlinks: ## Symlinks dotfiles into homedir
	for f in $(SYMLINKS); do \
		ln -sf $(PWD)/$$f ~/$$f ; \
	done

clean: ## Cleans symlinks and such
	for f in $(SYMLINKS) $(OHMYZSH) $(CLEANFILES) ; do \
		rm -rf ~/$$f ; \
	done

.PHONY: help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'
	 
