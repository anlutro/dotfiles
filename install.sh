#!/bin/sh

if [ -z "$HOME" ]; then
	echo '$HOME is empty, aborting'
	exit 1
fi

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
	ln -sf $sd/bash/bashrc $HOME/.bashrc
	ln -sf $sd/bash/aliases $HOME/.bash_aliases
	ln -sf $sd/bash/ps1 $HOME/.bash_ps1
}

install_compton() {
	ln -sf $sd/compton.conf $HOME/.config/compton.conf
}

install_dunst() {
	ln -sfT $sd/dunst $HOME/.config/dunst
}

install_git() {
	ln -sf $sd/git/config $HOME/.gitconfig
	ln -sf $sd/git/ignore_global $HOME/.gitignore_global
}

install_i3() {
	ln -sfT $sd/i3 $HOME/.config/i3
}

install_i3status() {
	ln -sfT $sd/i3status $HOME/.config/i3status
}

install_irssi() {
	[ -d $HOME/.irssi ] || mkdir -p $HOME/.irssi
	ln -sf $sd/irssi/default.theme $HOME/.irssi/default.theme
}

install_moc() {
	[ -d $HOME/.moc ] || mkdir -p $HOME/.moc
	ln -sfT $sd/moc/config $HOME/.moc/config
}

install_mutt() {
	ln -sfT $sd/muttrc $HOME/.muttrc
}

install_nano() {
	ln -sf $sd/nanorc $HOME/.nanorc
}

install_rtorrent() {
	ln -sf $sd/rtorrent.rc $HOME/.rtorrent.rc
}

install_subl() {
	ln -sfT $sd/sublime-text $HOME/.config/sublime-text-3/Packages/User
	ln -sf $sd/bin/sublp $HOME/bin/sublp
}

install_tmux() {
	ln -sf $sd/tmux.conf $HOME/.tmux.conf
}

install_urxvt() {
	if [ ! -d $vd/urxvt-perls ]; then
		git clone https://github.com/muennich/urxvt-perls $vd/urxvt-perls
	fi
	if [ ! -d $vd/urxvt-font-size ]; then
		git clone https://github.com/majutsushi/urxvt-font-size $vd/urxvt-font-size
	fi

	[ -d $HOME/.urxvt/ext ] || mkdir -p $HOME/.urxvt/ext
	ln -sf "$vd/urxvt-perls/url-select" $HOME/.urxvt/ext/url-select
	ln -sf "$vd/urxvt-perls/clipboard" $HOME/.urxvt/ext/clipboard
	ln -sf "$vd/urxvt-perls/keyboard-select" $HOME/.urxvt/ext/keyboard-select
	ln -sf "$vd/urxvt-font-size/font-size" $HOME/.urxvt/ext/font-size
}

vim_common() {
	# make sure this function is only called once
	[ $vim_common_installed ] && return;
	vim_common_installed=1

	if [ ! -d $vd/jellybeans.vim ]; then
		git clone https://github.com/nanotech/jellybeans.vim $vd/jellybeans.vim
	fi
	ln -sf ../../vendor/jellybeans.vim/colors/jellybeans.vim $sd/vim/colors/jellybeans.vim

	if command -v salt >/dev/null 2>&1; then
		echo "Installing salt-vim"
		if [ ! -d $vd/salt-vim ]; then
			git clone https://github.com/saltstack/salt-vim $vd/salt-vim
		fi
		ln -sf ../../vendor/salt-vim/ftdetect/sls.vim $sd/vim/ftdetect/sls.vim
		ln -sf ../../vendor/salt-vim/ftplugin/sls.vim $sd/vim/ftplugin/sls.vim
		ln -sf ../../vendor/salt-vim/syntax/sls.vim $sd/vim/syntax/sls.vim
	fi
}
install_vim() {
	vim_common

	ln -sfT $sd/vimrc $HOME/.vimrc

	[ -d $HOME/.vim ] || mkdir $HOME/.vim
	for file in $sd/vim/*; do
		ln -sfT $file $HOME/.vim/$(basename $file)
	done
}
install_nvim() {
	vim_common

	[ -d $HOME/.config/nvim ] || mkdir $HOME/.config/nvim
	ln -sfT $sd/vimrc $HOME/.config/nvim/init.vim
	for file in $sd/vim/*; do
		ln -sfT $file $HOME/.config/nvim/$(basename $file)
	done
}

install_X() {
	ln -sf $sd/x11/xsessionrc $HOME/.xsessionrc
	ln -sf $sd/x11/xresources $HOME/.Xresources
	if [ ! -f $sd/x11/xresources.local ]; then
		cp $sd/x11/xresources.local.default $sd/x11/xresources.local
	fi
	ln -sf $sd/x11/xresources.local $HOME/.Xresources.local

	[ -d $HOME/.config/fontconfig ] || mkdir -p $HOME/.config/fontconfig
	ln -sf $sd/fontconfig/fonts.conf $HOME/.config/fontconfig/fonts.conf
	if [ ! -f $sd/fontconfig/local.conf ]; then
		cp $sd/fontconfig/local.conf.default $sd/fontconfig/local.conf
	fi
	ln -sf $sd/fontconfig/local.conf $HOME/.config/fontconfig/local.conf
	rm -f $HOME/.fonts.conf

	if command -v gtk-launch >/dev/null 2>&1; then
		echo "Installing GTK themes"
		ln -sf $sd/gtkrc-2.0 $HOME/.gtkrc-2.0

		if [ ! -d $vd/paper-gtk-theme ]; then
			git clone https://github.com/snwh/paper-gtk-theme $vd/paper-gtk-theme
		fi
		ln -sfT $vd/paper-gtk-theme/Paper $HOME/.themes/Paper

		if [ ! -d $vd/zuki-themes ]; then
			git clone https://github.com/lassekongo83/zuki-themes $vd/zuki-themes
		fi
		ln -sfT $vd/zuki-themes/Zukiwi $HOME/.themes/Zukiwi
		ln -sfT $vd/zuki-themes/Zukitwo $HOME/.themes/Zukitwo
		ln -sfT $vd/zuki-themes/Zukitre $HOME/.themes/Zukitre
	fi
}


install bash
install compton
install dunst
install git
install i3
install i3status
install irssi
install moc
install mutt
install nano
install rtorrent
install subl
install tmux
install urxvt
install vim
install nvim
install X


echo "Installing ~/bin files"
[ -d $HOME/bin ] || mkdir $HOME/bin
if [ -d /etc/apache2 ]; then
	ln -sf $sd/bin/a2es $HOME/bin/a2es
fi
ln -sf $sd/bin/art $HOME/bin/art
ln -sf $sd/bin/genpw $HOME/bin/genpw
ln -sf $sd/bin/templ $HOME/bin/templ
