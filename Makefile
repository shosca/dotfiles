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

all: ohmyzsh symlinks base16

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

neobundle:
	mkdir -p ~/.vim/bundle ; \
	if [[ ! -d ~/.vim/bundle/neobundle.vim ]] ; then \
		git clone https://github.com/Shougo/neobundle.vim.git ~/.vim/bundle/neobundle.vim ; \
	fi ; \
	if [[ ! -d ~/.vim/bundle/vimproc.vim ]] ; then \
		git clone https://github.com/Shougo/vimproc.vim.git ~/.vim/bundle/vimproc.vim ; \
	fi ; \
	ln -sf $(PWD)/.vimrc ~/.vimrc ; \
	make -C ~/.vim/bundle/vimproc.vim/ && \
	vim -N -u ~/.vimrc -c "try | NeoBundleUpdate! | finally | qall! | endtry" \
		-U NONE -i NONE -V1 -e -s

symlinks:
	for f in $(SYMLINKS); do \
		ln -sf $(PWD)/$$f ~/$$f ; \
	done

clean:
	for f in $(SYMLINKS) $(OHMYZSH) $(CLEANFILES) ; do \
		rm -rf ~/$$f ; \
	done
