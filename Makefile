PWD=$(shell pwd)
OHMYZSH=.oh-my-zsh
OHMYZSHFILES=\
	$(OHMYZSH) \
	.zshrc
VIMFILES= \
	.vim \
	.vimbackup \
	.viminfo \
	.vimswap \
	.vimundo \
	.vimviews
SYMLINKS= \
	.ackrc \
	.ctags \
	.eslintrc \
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

install: install-vim install-zsh install-symlinks ## Installs all

install-zsh: ## Sets up zsh
	ln -sf $(PWD)/.zshrc ~/.zshrc ; \
	if [[ ! -e ~/$(OHMYZSH) ]]; then \
		git clone https://github.com/robbyrussell/oh-my-zsh.git ~/$(OHMYZSH) ; \
	else \
		cd ~/$(OHMYZSH) && git pull ; \
	fi

install-vim: ## Sets up vim
	mkdir -p ~/.vim/bundle ; \
	mkdir -p ~/.config/; \
	ln -sf ~/.vim ~/.config/nvim ; \
	ln -sf $(PWD)/vim/vimrc ~/.vim/vimrc ; \
	ln -sf $(PWD)/vim/vimrc ~/.config/nvim/init.vim; \
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

install-symlinks: ## Symlinks dotfiles into homedir
	for f in $(SYMLINKS); do \
		ln -sf $(PWD)/$$f ~/$$f ; \
	done

clean: clean-symlinks clean-vim clean-zsh ## Cleans all configs

clean-symlinks: ## Cleans symlinks and such
	for f in $(SYMLINKS) ; do \
		rm -rf ~/$$f ; \
	done

clean-zsh: ## Cleans zsh config files
	for f in $(OHMYZSHFILES) ; do \
		rm -rf ~/$$f ; \
	done

clean-vim: ## Cleans vim config files
	for f in $(VIMFILES) ; do \
		rm -rf ~/$$f ; \
	done

.PHONY: help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
	 
