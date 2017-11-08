#!/bin/sh

if [ -z "$HOME" ]; then
	echo '$HOME is empty, aborting'
	exit 1
fi

if [ -z "$HOST" ]; then
	HOST=$(hostname)
fi

if [ ! -d $HOME/.local ]; then
	mkdir -p $HOME/.local
	chmod 700 $HOME/.local
fi
if [ ! -d $HOME/.local/bin ]; then
	mkdir -p $HOME/.local/bin
fi
bindir=$HOME/.local/bin

root=$(dirname "$(readlink -f "$0")")
configs=$root/configs
scripts=$root/scripts
local="$root/local/$HOST"
vendor=$root/vendor

install() {
	name="$1"
	func="install_$(echo $1 | tr -s '-' '_')"
	cmd=${2:-$1}
	if command -v $cmd >/dev/null 2>&1; then
		echo -n "Setting up $name... "
		$func
		echo "done"
	fi
}

_install_fzf() {
	if [ ! -d $vendor/fzf ]; then
		git clone https://github.com/junegunn/fzf $vendor/fzf
	fi
	if ! command -v fzf >/dev/null 2>&1; then
		$vendor/fzf/install --bin
	fi
}

install_bash() {
	ln -sf $configs/shell/bashrc $HOME/.bashrc
	[ -f $HOME/.bash_aliases ] && rm $HOME/.bash_aliases
	[ -f $HOME/.bash_ps1 ] && rm $HOME/.bash_ps1
	ln -sf $configs/shell/logout $HOME/.bash_logout
	_install_fzf
}

install_compton() {
	ln -sf $configs/compton.conf $HOME/.config/compton.conf
}

install_dunst() {
	mkdir -p $HOME/.config/dunst
	ln -sf $configs/dunstrc $HOME/.config/dunst/dunstrc
}

install_feh() {
	if [ -L $HOME/.fehbg ] && [ -f $local/fehbg ]; then
		rm $HOME/.fehbg
		cp $local/fehbg $HOME/.fehbg
	fi
}

install_git() {
	local local_conf
	local git_version=$(git --version | grep -oP '[\d+.]+')

	if echo $git_version | grep -q '^1'; then
		ln -sf $configs/git/config $HOME/.gitconfig
		ln -sf $configs/git/ignore_global $HOME/.gitignore_global
		local_conf=$HOME/.gitconfig.local
	else
		[ -e $HOME/.gitconfig ] && rm $HOME/.gitconfig
		[ -e $HOME/.gitignore_global ] && rm $HOME/.gitignore_global
		[ -e $HOME/.gitconfig.local ] && \
			mv $HOME/.gitconfig.local $HOME/.config/git/config.local

		local conf_path=$HOME/.config/git
		mkdir -p $conf_path
		ln -sf $configs/git/config $conf_path/config
		ln -sf $configs/git/ignore_global $conf_path/ignore
		local_conf=$conf_path/config.local
	fi

	local git_config="git config --file $local_conf"

	if [ ! -f $local_conf ] || ! $git_config user.name > /dev/null; then
		$git_config user.name 'Andreas Lutro'
		$git_config user.email 'anlutro@gmail.com'
	fi

	if echo $git_version | grep -q '^1'; then
		if [ ! -f $local_conf ] || ! $git_config core.excludesfile > /dev/null; then
			$git_config core.excludesfile .gitignore_global
		fi
	else
		if [ -f $local_conf ]; then
			$git_config --unset core.excludesfile
		fi
	fi

	ln -sf $scripts/git-abort.sh $bindir/git-abort
	ln -sf $scripts/git-with-sshkey.sh $bindir/git-with-sshkey
	ln -sf $scripts/git-find-large-files.sh $bindir/git-find-large-files
	ln -sf $scripts/git-all-my-logs.sh $bindir/git-all-my-logs
}

install_gtk() {
	ln -sf $configs/gtk/gtk2-rc $HOME/.gtkrc-2.0

	mkdir -p $HOME/.themes
	mkdir -p $HOME/.local/share/themes

	if [ ! -d $vendor/zuki-themes ]; then
		git clone https://github.com/lassekongo83/zuki-themes $vendor/zuki-themes
	fi
	ln -sfT $vendor/zuki-themes/Zukiwi $HOME/.themes/Zukiwi
	ln -sfT $vendor/zuki-themes/Zukiwi $HOME/.local/share/themes/Zukiwi
	ln -sfT $vendor/zuki-themes/Zukitwo $HOME/.themes/Zukitwo
	ln -sfT $vendor/zuki-themes/Zukitwo $HOME/.local/share/themes/Zukitwo
	ln -sfT $vendor/zuki-themes/Zukitre $HOME/.themes/Zukitre
	ln -sfT $vendor/zuki-themes/Zukitre $HOME/.local/share/themes/Zukitre

	if [ ! -d $vendor/paper-gtk-theme ]; then
		git clone https://github.com/snwh/paper-gtk-theme $vendor/paper-gtk-theme
	fi
	ln -sfT $vendor/paper-gtk-theme/Paper $HOME/.themes/Paper
	ln -sfT $vendor/paper-gtk-theme/Paper $HOME/.local/share/themes/Paper

	if [ -d $HOME/.config/gtk-3.0 ]; then
		ln -sf $configs/gtk/gtk3-settings.ini $HOME/.config/gtk-3.0/settings.ini
	fi
}

install_i3() {
	mkdir -p $HOME/.config/i3
	ln -sf $configs/i3/i3.conf $HOME/.config/i3/config

	ln -sf $scripts/i3-get.py $bindir/i3-get
	ln -sf $scripts/i3-switch.sh $bindir/i3-switch
}

install_i3blocks() {
	local conf_path=$HOME/.config/i3blocks

	[ -d $vendor/i3blocks ] || git clone https://github.com/vivien/i3blocks $vendor/i3blocks
	mkdir -p $conf_path
	ln -sf $configs/i3/i3blocks.conf $conf_path/config

	[ -L $conf_path/scripts ] && rm $conf_path/scripts
	[ ! -d $conf_path/scripts ] && mkdir -p $conf_path/scripts

	for f in $vendor/i3blocks/scripts/*; do
		filepath=$(readlink -f $f)
		filename=$(basename $f)
		ln -sf $filepath $conf_path/scripts/$filename
	done

	for f in $configs/i3/block-scripts/*; do
		filepath=$(readlink -f $f)
		filename=$(basename $f)
		ln -sf $filepath $conf_path/scripts/$filename
	done
}

install_i3status() {
	mkdir -p $HOME/.config/i3status
	ln -sf $configs/i3/i3status.conf $HOME/.config/i3status/config
}

install_irssi() {
	mkdir -p $HOME/.irssi
	ln -sf $configs/irssi/default.theme $HOME/.irssi/default.theme
	ln -sfT $configs/irssi/scripts $HOME/.irssi/scripts
}

install_moc() {
	mkdir -p $HOME/.moc
	ln -sfT $configs/moc.conf $HOME/.moc/config
}

install_mutt() {
	if [ ! -e $HOME/.muttrc ] || [ -L $HOME/.muttrc ]; then
		ln -sfT $configs/muttrc $HOME/.muttrc
	fi
}

install_nano() {
	ln -sf $configs/nanorc $HOME/.nanorc
}

install_python() {
	ln -sf $scripts/templ.py $bindir/templ
}

install_subl() {
	pkgdir=$HOME/.config/sublime-text-3/Packages
	userdir=$pkgdir/User
	mkdir -p $pkgdir
	if [ -d $userdir ] && [ ! -L $userdir ]; then
		mv $userdir $userdir.bak
	fi
	ln -sfT $configs/sublime-text $userdir
	ln -sf $scripts/sublp.sh $bindir/sublp
}

install_taskwarrior() {
	ln -sf $configs/taskrc $HOME/.taskrc
}

install_tmux() {
	ln -sf $configs/tmux.conf $HOME/.tmux.conf
}

_install_urxvt_perl() {
	if [ -f "$vendor/urxvt-perls/$1" ]; then
		ln -sf "$vendor/urxvt-perls/$1" $HOME/.urxvt/ext/$1
	elif [ -f "$vendor/urxvt-perls/deprecated/$1" ]; then
		ln -sf "$vendor/urxvt-perls/deprecated/$1" $HOME/.urxvt/ext/$1
	fi
}

install_urxvt() {
	if [ ! -d $vendor/urxvt-perls ]; then
		git clone https://github.com/muennich/urxvt-perls $vendor/urxvt-perls
	fi
	if [ ! -d $vendor/urxvt-font-size ]; then
		git clone https://github.com/majutsushi/urxvt-font-size $vendor/urxvt-font-size
	fi

	mkdir -p $HOME/.urxvt/ext
	_install_urxvt_perl url-select
	_install_urxvt_perl clipboard
	_install_urxvt_perl keyboard-select
	ln -sf "$vendor/urxvt-font-size/font-size" $HOME/.urxvt/ext/font-size
}

vim_common() {
	# make sure this function is only called once
	[ -n "$vim_common_installed" ] && return
	vim_common_installed=1

	if [ ! -d $vendor/jellybeans.vim ]; then
		git clone https://github.com/nanotech/jellybeans.vim $vendor/jellybeans.vim
	fi
	ln -sf ../../../vendor/jellybeans.vim/colors/jellybeans.vim $configs/vim/colors/jellybeans.vim

	if command -v salt >/dev/null 2>&1; then
		echo -n "salt-vim... "
		if [ ! -d $vendor/salt-vim ]; then
			git clone https://github.com/saltstack/salt-vim $vendor/salt-vim
		fi
		ln -sf ../../../vendor/salt-vim/ftdetect/sls.vim $configs/vim/ftdetect/sls.vim
		ln -sf ../../../vendor/salt-vim/ftplugin/sls.vim $configs/vim/ftplugin/sls.vim
		ln -sf ../../../vendor/salt-vim/syntax/sls.vim $configs/vim/syntax/sls.vim
	fi
}

install_vim() {
	vim_common

	ln -sfT $configs/vim/init.vim $HOME/.vimrc

	mkdir -p $HOME/.vim
	for file in $configs/vim/*; do
		if [ $file != $configs/vim/init.vim ]; then
			ln -sfT $file "$HOME/.vim/$(basename "$file")"
		fi
	done
}

install_nvim() {
	vim_common

	mkdir -p $HOME/.config/nvim
	for file in $configs/vim/*; do
		ln -sfT $file "$HOME/.config/nvim/$(basename "$file")"
	done
}

install_xdg() {
	ln -sf $configs/user-dirs.dirs $HOME/.config/user-dirs.dirs
}

install_xorg() {
	ln -sf $configs/x11/xinitrc $HOME/.xinitrc
	ln -sf $configs/x11/xsettings $HOME/.xsettings
	ln -sf $configs/x11/xdefaults $HOME/.Xdefaults
	if [ -f $local/xresources ]; then
		ln -sf $local/xresources $HOME/.Xresources
	elif [ -L $HOME/.Xresources ]; then
		rm $HOME/.Xresources
	fi
	if [ -e $HOME/.xsessionrc ]; then
		rm $HOME/.xsessionrc
	fi
	if [ -e $HOME/.xprograms ]; then
		rm $HOME/.xprograms
	fi

	FC_DIR=$HOME/.config/fontconfig/conf.d
	mkdir -p $FC_DIR
	ln -sf $configs/fontconfig/fonts.conf $FC_DIR/00-common.conf
	if [ -f $local/fonts.local.conf ]; then
		ln -sf $local/fonts.local.conf $FC_DIR/99-local.conf
	elif [ -L $FC_DIR/99-local.conf ]; then
		rm $FC_DIR/99-local.conf
	fi
	rm -f $HOME/.fonts.conf
	rm -f $HOME/.config/fontconfig/fonts.conf
	rm -f $HOME/.config/fontconfig/local.conf

	ln -sf $scripts/lockscreen.sh $bindir/lockscreen
	if [ -f $local/xrandrinit ]; then
		ln -sf $local/xrandrinit $HOME/.xrandrinit
	elif [ -L $HOME/.xrandrinit ]; then
		rm $HOME/.xrandrinit
	fi

	if [ ! -e $HOME/.xautolock ] && [ ! -L $HOME/.xautolock ]; then
		ln -sf $configs/x11/xautolock $HOME/.xautolock
	fi
}

install_zsh() {
	ln -sf $configs/shell/zshrc $HOME/.zshrc
	ln -sf $configs/shell/profile $HOME/.zprofile
	ln -sf $configs/shell/logout $HOME/.zlogout
	_install_fzf
}


echo -n "Shared configs... "
ln -sf $configs/shell/profile $HOME/.profile
ln -sf $configs/shell/inputrc $HOME/.inputrc
[ -L $HOME/.aliases ] && rm $HOME/.aliases
[ -L $HOME/.shell_aliases ] && rm $HOME/.shell_aliases
[ -L $HOME/.shell_vars ] && rm $HOME/.shell_vars
ln -sf $configs/shell/shrc $HOME/.shrc
if [ ! -d $HOME/.ssh ]; then
	mkdir -p $HOME/.ssh
	chmod 700 $HOME/.ssh
fi
ln -sf $configs/ssh/rc $HOME/.ssh/rc
echo "done"


echo -n "Linking various bin scripts... "
ln -sf $scripts/notes.sh $bindir/notes
ln -sf $scripts/journal.sh $bindir/journal
ln -sf $scripts/init-project.py $bindir/init-project
echo "done"


install bash
install compton
install dunst
install feh
install git
install gtk gtk-update-icon-cache
install i3
install i3blocks
install i3status
install irssi
install moc mocp
install mutt
install nano
install python
install subl
install taskwarrior task
install tmux
install urxvt
install vim
install nvim
install xorg Xorg
install xdg xdg-open
install zsh


# look for broken symlinks
echo "\nLooking for broken symlinks..."
find $configs -xtype l
find $scripts -xtype l
find $bindir -xtype l
