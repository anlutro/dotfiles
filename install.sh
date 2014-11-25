#!/usr/bin/env sh

# script directory
sd=$(dirname $(readlink -f "$0"))

echo "Linking bash files ..."
ln -sf $sd/bash/rc.sh ~/.bashrc
ln -sf $sd/bash/aliases.sh ~/.bash_aliases
ln -sf $sd/bash/ps1.sh ~/.bash_ps1

if command -v nano >/dev/null 2>&1; then
	echo "Linking nanorc ..."
	ln -sf $sd/nanorc ~/.nanorc
fi

if command -v git >/dev/null 2>&1; then
	echo "Linking git files ..."
	ln -sf $sd/git/config ~/.gitconfig
	ln -sf $sd/git/ignore_global ~/.gitignore_global
fi

if command -v conky >/dev/null 2>&1; then
	echo "Linking conkyrc ..."
	ln -sf $sd/conkyrc ~/.conkyrc
fi

if command -v tmux >/dev/null 2>&1; then
	echo "Linking tmux.conf ..."
	ln -sf $sd/tmux.conf ~/.tmux.conf
fi

if command -v colordiff >/dev/null 2>&1; then
	echo "Linking colordiffrc ..."
	ln -sf $sd/colordiffrc ~/.colordiffrc
fi

if command -v openbox >/dev/null 2>&1; then
	echo "Linking openbox config dir ..."
	ln -sfT $sd/dotconfig/openbox ~/.config/openbox
fi

if command -v tint2 >/dev/null 2>&1; then
	echo "Linking tint2 config ..."
	ln -sfT $sd/dotconfig/tint2/tint2rc ~/.config/tint2/tint2rc
fi

if command -v xfce4-terminal >/dev/null 2>&1; then
	echo "Linking xfce4-terminal config dir ..."
	ln -sfT $sd/dotconfig/xfce4/terminal ~/.config/xfce4/terminal
fi

if command -v terminator >/dev/null 2>&1; then
	echo "Linking terminator config dir ..."
	ln -sfT $sd/dotconfig/terminator ~/.config/terminator
fi

if command -v gsimplecal >/dev/null 2>&1; then
	echo "Linking gsimplecal config dir ..."
	ln -sfT $sd/dotconfig/gsimplecal ~/.config/gsimplecal
fi

# Link all files in ./bin to ~/bin
for f in $sd/bin/*; do
	if [ ! -d ~/bin ]; then mkdir ~/bin; fi
	file=$(basename $f)
	path=$(readlink -f $f)
	ln -sf $path ~/bin/$file
	echo "Linking bin/$file ..."
done
