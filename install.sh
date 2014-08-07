#!/usr/bin/env sh

ln -sf ./bash/aliases ~/.bash_aliases
ln -sf ./bash/rc ~/.bashrc

if [[ hash git 2>/dev/null ]]; then
	ln -sf ./git/config ~/.gitconfig
	ln -sf ./git/ignore_global ~/.gitignore_global
fi

if [[ hash conky 2>/dev/null ]]; then
	ln -sf ./conkyrc ~/.conkyrc
fi

if [[ hash tmux 2>/dev/null ]]; then
	ln -sf ./tmux.conf ~/.tmux.conf
fi

if [[ hash colordiff 2>/dev/null ]]; then
	ln -sf ./colordiffrc ~/.colordiffrc
fi

if [[ hash openbox 2>/dev/null ]]; then
	ln -sfT ./openbox ~/.config/openbox
fi
