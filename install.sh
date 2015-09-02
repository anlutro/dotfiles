#!/bin/sh

# script directory
sd=$(dirname $(readlink -f "$0"))
# vendor directory
vd=$sd/vendor

install() {
	if command -v $1 >/dev/null 2>&1; then
		echo "Installing $1 files"
		"install_$(echo $1 | tr -s '-' '_')"
	fi
}

install_bash() {
	ln -sf $sd/bash/bashrc ~/.bashrc
	ln -sf $sd/bash/aliases ~/.bash_aliases
	ln -sf $sd/bash/ps1 ~/.bash_ps1
}

install_compton() {
	ln -sf $sd/compton.conf ~/.config/compton.conf
}

install_conky() {
	ln -sf $sd/conkyrc ~/.conkyrc
}

install_dunst() {
	ln -sfT $sd/dunst ~/.config/dunst
}

install_git() {
	ln -sf $sd/git/config ~/.gitconfig
	ln -sf $sd/git/ignore_global ~/.gitignore_global
}

install_gsimplecal() {
	ln -sfT $sd/gsimplecal ~/.config/gsimplecal
}

install_i3() {
	ln -sfT $sd/i3 ~/.config/i3
}

install_i3status() {
	ln -sfT $sd/i3status ~/.config/i3status
}

install_irssi() {
	[ -d ~/.irssi ] || mkdir -p ~/.irssi
	ln -sf $sd/irssi/default.theme ~/.irssi/default.theme
}

install_mutt() {
	ln -sfT $sd/muttrc ~/.muttrc
}

install_nano() {
	ln -sf $sd/nanorc ~/.nanorc
}

install_openbox() {
	ln -sfT $sd/openbox ~/.config/openbox
}

install_rtorrent() {
	ln -sf $sd/rtorrent.rc ~/.rtorrent.rc
}

install_subl() {
	ln -sfT $sd/sublime-text ~/.config/sublime-text-3/Packages/User
	ln -sf $sd/bin/sublp ~/bin/sublp
}

install_terminator() {
	ln -sfT $sd/terminator ~/.config/terminator
}

install_tint2() {
	ln -sf $sd/tint2/tint2rc ~/.config/tint2/tint2rc
}

install_tmux() {
	ln -sf $sd/tmux.conf ~/.tmux.conf
}

install_urxvt() {
	if [ ! -d $vd/urxvt-perls ]; then
		git clone https://github.com/muennich/urxvt-perls $vd/urxvt-perls
	fi

	[ -d ~/.urxvt/ext ] || mkdir -p ~/.urxvt/ext
	ln -sf $vd/urxvt-perls/url-select ~/.urxvt/ext/url-select
	ln -sf $vd/urxvt-perls/clipboard ~/.urxvt/ext/clipboard
	ln -sf $vd/urxvt-perls/keyboard-select ~/.urxvt/ext/keyboard-select
}

vim_common() {
	if [ ! -d $vd/jellybeans.vim ]; then
		git clone https://github.com/nanotech/jellybeans.vim $vd/jellybeans.vim
	fi

	ln -sf $vd/jellybeans.vim/colors/jellybeans.vim $sd/vim/colors/jellybeans.vim
}
install_vim() {
	vim_common
	ln -sfT $sd/vimrc ~/.vimrc
	ln -sfT $sd/vim ~/.vim
}
install_nvim() {
	vim_common
	ln -sfT $sd/vimrc ~/.nvimrc
	ln -sfT $sd/vim ~/.nvim
}

install_X() {
	ln -sf $sd/x11/xsessionrc ~/.xsessionrc
	ln -sf $sd/x11/xresources ~/.Xresources
	if [ ! -f $sd/x11/xresources.local ]; then
		cp $sd/x11/xresources.local.default $sd/x11/xresources.local
	fi
	ln -sf $sd/x11/xresources.local ~/.Xresources.local

	[ -d ~/.config/fontconfig ] || mkdir -p ~/.config/fontconfig
	ln -sf $sd/fontconfig/fonts.conf ~/.config/fontconfig/fonts.conf
	if [ ! -f $sd/fontconfig/local.conf ]; then
		cp $sd/fontconfig/local.conf.default $sd/fontconfig/local.conf
	fi
	ln -sf $sd/fontconfig/local.conf ~/.config/fontconfig/local.conf
	rm -f ~/.fonts.conf

	ln -sf $sd/gtkrc-2.0 ~/.gtkrc-2.0
}

install_xfce4_terminal() {
	ln -sfT $sd/xfce4-terminal ~/.config/xfce4/terminal
}


install bash
install compton
install conky
install dunst
install git
install gsimplecal
install i3
install i3status
install irssi
install mutt
install nano
install openbox
install rtorrent
install subl
install terminator
install tint2
install tmux
install urxvt
install vim
install nvim
install X
install xfce4-terminal


echo "Installing ~/bin files"
[ -d ~/bin ] || mkdir ~/bin
if [ -d /etc/apache2 ]; then
	ln -sf $sd/bin/a2es ~/bin/a2es
fi
ln -sf $sd/bin/art ~/bin/art
ln -sf $sd/bin/genpw ~/bin/genpw
ln -sf $sd/bin/templ ~/bin/templ
