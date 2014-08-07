#!/usr/bin/env sh

# script directory
sd=$(dirname $(readlink -f "$0"))

ln -sf $sd/bash/aliases ~/.bash_aliases
ln -sf $sd/bash/rc ~/.bashrc

if [[ hash git 2>/dev/null ]]; then
	ln -sf $sd/git/config ~/.gitconfig
	ln -sf $sd/git/ignore_global ~/.gitignore_global
fi

if [[ hash conky 2>/dev/null ]]; then
	ln -sf $sd/conkyrc ~/.conkyrc
fi

if [[ hash tmux 2>/dev/null ]]; then
	ln -sf $sd/tmux.conf ~/.tmux.conf
fi

if [[ hash colordiff 2>/dev/null ]]; then
	ln -sf $sd/colordiffrc ~/.colordiffrc
fi

if [[ hash openbox 2>/dev/null ]]; then
	ln -sfT $sd/openbox ~/.config/openbox
fi
