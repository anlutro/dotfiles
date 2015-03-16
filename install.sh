#!/usr/bin/env sh

# script directory
sd=$(dirname $(readlink -f "$0"))

echo "Linking bash files"
ln -sf $sd/bash/rc.sh ~/.bashrc
ln -sf $sd/bash/aliases.sh ~/.bash_aliases
ln -sf $sd/bash/ps1.sh ~/.bash_ps1

if command -v nano >/dev/null 2>&1; then
	echo "Linking nanorc"
	ln -sf $sd/nanorc ~/.nanorc
fi

if command -v git >/dev/null 2>&1; then
	echo "Linking git files"
	ln -sf $sd/git/config ~/.gitconfig
	ln -sf $sd/git/ignore_global ~/.gitignore_global
fi

if command -v conky >/dev/null 2>&1; then
	echo "Linking conkyrc"
	ln -sf $sd/conkyrc ~/.conkyrc
fi

if command -v compton >/dev/null 2>&1; then
	echo "Linking compton.conf"
	ln -sf $sd/compton.conf ~/.config/compton.conf
fi

if command -v tmux >/dev/null 2>&1; then
	echo "Linking tmux.conf"
	ln -sf $sd/tmux.conf ~/.tmux.conf
fi

if command -v colordiff >/dev/null 2>&1; then
	echo "Linking colordiffrc"
	ln -sf $sd/colordiffrc ~/.colordiffrc
fi

if command -v openbox >/dev/null 2>&1; then
	echo "Linking openbox config dir"
	ln -sfT $sd/openbox ~/.config/openbox
fi

if command -v tint2 >/dev/null 2>&1; then
	echo "Linking tint2 config"
	ln -sf $sd/tint2/tint2rc ~/.config/tint2/tint2rc
fi

if command -v xfce4-terminal >/dev/null 2>&1; then
	echo "Linking xfce4-terminal config dir"
	ln -sfT $sd/xfce4-terminal ~/.config/xfce4/terminal
fi

if command -v terminator >/dev/null 2>&1; then
	echo "Linking terminator config dir"
	ln -sfT $sd/terminator ~/.config/terminator
fi

if command -v gsimplecal >/dev/null 2>&1; then
	echo "Linking gsimplecal config dir"
	ln -sfT $sd/gsimplecal ~/.config/gsimplecal
fi

if command -v thunar >/dev/null 2>&1; then
	echo "Linking thunar config dir"
	ln -sfT $sd/thunar ~/.config/Thunar
fi

if command -v i3 >/dev/null 2>&1; then
	echo "Linking i3 config dir"
	ln -sfT $sd/i3 ~/.config/i3
fi

if command -v i3status >/dev/null 2>&1; then
	echo "Linking i3status config dir"
	ln -sfT $sd/i3status ~/.config/i3status
fi

# Link ~/bin files
if [ ! -d ~/bin ]; then mkdir ~/bin; fi
echo "Linking ~/bin files"

ln -sf $sd/bin/a2es ~/bin/a2es
ln -sf $sd/bin/art ~/bin/art
ln -sf $sd/bin/genpw ~/bin/genpw
ln -sf $sd/bin/templ ~/bin/templ

if command -v X >/dev/null 2>&1; then
	ln -sf $sd/bin/lock ~/bin/lock
	ln -sf $sd/bin/suspend ~/bin/suspend
	ln -sf $sd/xsessionrc ~/.xsessionrc
fi
