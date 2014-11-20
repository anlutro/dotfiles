#!/usr/bin/env sh

# script directory
sd=$(dirname $(readlink -f "$0"))

echo "Linking bash files..."
ln -sf $sd/bash/aliases.sh ~/.bash_aliases
ln -sf $sd/bash/rc.sh ~/.bashrc

if command -v nano >/dev/null 2>&1; then
	echo "Linking nanorc..."
	ln -sf $sd/nanorc ~/.nanorc
fi

if command -v git >/dev/null 2>&1; then
	echo "Linking git files..."
	ln -sf $sd/git/config ~/.gitconfig
	ln -sf $sd/git/ignore_global ~/.gitignore_global
fi

if command -v conky >/dev/null 2>&1; then
	echo "Linking conkyrc..."
	ln -sf $sd/conkyrc ~/.conkyrc
fi

if command -v tmux >/dev/null 2>&1; then
	echo "Linking tmux.conf..."
	ln -sf $sd/tmux.conf ~/.tmux.conf
fi

if command -v colordiff >/dev/null 2>&1; then
	echo "Linking colordiffrc..."
	ln -sf $sd/colordiffrc ~/.colordiffrc
fi

if command -v openbox >/dev/null 2>&1; then
	echo "Linking openbox config dir..."
	ln -sfT $sd/openbox ~/.config/openbox
fi

if command -v tint2 >/dev/null 2>&1; then
	echo "Linking tint2 config dir..."
	ln -sfT $sd/tint2 ~/.config/tint2
fi

if command -v x-terminal-emulator >/dev/null 2>&1; then
	echo "Linking x-terminal-emulator config dir..."
	ln -sfT $sd/xfce4/terminal ~/.config/xfce4/terminal
fi

if command -v terminator >/dev/null 2>&1; then
	echo "Linking terminator config dir..."
	ln -sfT $sd/terminator ~/.config/terminator
fi
