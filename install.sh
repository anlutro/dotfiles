#!/bin/sh

# script directory
sd=$(dirname $(readlink -f "$0"))

echo "Linking bash files"
ln -sf $sd/bash/bashrc ~/.bashrc
ln -sf $sd/bash/aliases ~/.bash_aliases
ln -sf $sd/bash/ps1 ~/.bash_ps1

if command -v X >/dev/null 2>&1; then
	echo "Linking X11 files"
	ln -sf $sd/x11/xsessionrc ~/.xsessionrc
	ln -sf $sd/x11/xresources ~/.Xresources
	if [ ! -f $sd/x11/xresources.local ]; then
		cp $sd/x11/xresources.local.default $sd/x11/xresources.local
	fi
	ln -sf $sd/x11/xresources.local ~/.Xresources.local

	[ -d ~/.config/fontconfig ] || mkdir -p ~/.config/fontconfig
	echo "Linking fonts.conf"
	ln -sf $sd/fontconfig/fonts.conf ~/.config/fontconfig/fonts.conf
	if [ ! -f $sd/fontconfig/local.conf ]; then
		cp $sd/fontconfig/local.conf.default $sd/fontconfig/local.conf
	fi
	ln -sf $sd/fontconfig/local.conf ~/.config/fontconfig/local.conf
	rm -f ~/.fonts.conf
fi

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

if command -v i3 >/dev/null 2>&1; then
	echo "Linking i3 config dir"
	ln -sfT $sd/i3 ~/.config/i3
fi

if command -v i3status >/dev/null 2>&1; then
	echo "Linking i3status config dir"
	ln -sfT $sd/i3status ~/.config/i3status
fi

if command -v urxvt >/dev/null 2>&1; then
	if [ ! -d $sd/urxvt-perls ]; then
		git clone https://github.com/muennich/urxvt-perls $sd/urxvt-perls
	fi

	[ -d ~/.urxvt/ext ] || mkdir -p ~/.urxvt/ext
	echo "Linking urxvt scripts"
	ln -sf $sd/urxvt-perls/url-select ~/.urxvt/ext/url-select
	ln -sf $sd/urxvt-perls/clipboard ~/.urxvt/ext/clipboard
	ln -sf $sd/urxvt-perls/keyboard-select ~/.urxvt/ext/keyboard-select
fi

if command -v irssi >/dev/null 2>&1; then
	[ -d ~/.irssi ] || mkdir -p ~/.irssi
	echo "Linking irssi files"
	ln -sf $sd/irssi/default.theme ~/.irssi/default.theme
fi

if command -v subl >/dev/null 2>&1; then
	echo "Linking Sublime Text 3 directory Packages/User"
	ln -sfT $sd/sublime-text ~/.config/sublime-text-3/Packages/User
fi

[ -d ~/bin ] || mkdir ~/bin
echo "Linking ~/bin files"
if [ -f /etc/apache2 ]; then
	ln -sf $sd/bin/a2es ~/bin/a2es
fi
if command -v subl >/dev/null 2>&1; then
	ln -sf $sd/bin/sublp ~/bin/sublp
fi
ln -sf $sd/bin/art ~/bin/art
ln -sf $sd/bin/genpw ~/bin/genpw
ln -sf $sd/bin/templ ~/bin/templ
