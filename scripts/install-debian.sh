#!/bin/bash

confirm() {
	read -p "$* [Y/n] "
	if [ -z "$REPLY" ] || [[ "$REPLY" =~ ^[Yy] ]]; then
		return 0
	fi
	return 1
}

apt_inst='apt-get -y install --no-install-recommends'

apt-get update && apt-get -y dist-upgrade
$apt_inst git vim tree curl irssi zip fuse psmisc jq bc silversearcher-ag \
	policykit-1 sudo apt-transport-https network-manager

usermod -a -G sudo,root,adm,staff,systemd-journal andreas

if confirm "Install X11, i3 and utilities?"; then
	$apt_inst xserver-xorg-{core,input-{kbd,mouse,evdev}} x11-xserver-utils \
		dbus-x11 xclip rofi dunst libnotify-bin scrot imagemagick xdg-user-dirs \
		feh rxvt-unicode-256color i3-wm i3lock i3blocks xinit xautolock

	mv /etc/fonts/conf.d/??-user.conf /etc/fonts/conf.d/98-user.conf
	mv /etc/fonts/conf.d/??-local.conf /etc/fonts/conf.d/98-local.conf

	if confirm "Install laptop utilities?"; then
		$apt_inst pm-utils xbacklight
	fi

	if confirm "Install MS TrueType fonts?"; then
		$apt_inst ttf-mscorefonts-installer
	fi

	if confirm "Install Sublime Text?"; then
		curl -fsSL https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor \
			> /etc/apt/trusted.gpg.d/sublimetext.gpg
		echo "deb https://download.sublimetext.com/ apt/dev/" \
			> /etc/apt/sources.list.d/sublime-text.list
		apt-get update && apt-get install sublime-text
	fi
fi

if confirm "Install Dropbox?"; then
	file=$(curl -s https://linux.dropbox.com/packages/debian/ | \
		grep -oP 'href="dropbox_\d{4}.*amd64.deb"' | cut -d\" -f2 | sort | tail -1)
	wget https://linux.dropbox.com/packages/debian/$file
	dpkg -i $file
	apt-get install -f
	rm $file
fi

if confirm "Install Docker?"; then
	curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor \
		> /etc/apt/trusted.gpg.d/docker.gpg
	echo "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" \
		> /etc/apt/sources.list.d/docker.list
	apt-get update && apt-get install docker-ce
	usermod -a -G docker andreas
fi

echo
echo "Finished! Note that some packages have been left out:"
echo "  * xserver-xorg-video-intel (in case you're using nvidia)"
echo "  * xserver-xorg-input-synaptics (in case you want to use libinput)"
echo "  * chromium (in case you want to get chrome instead)"
echo "Look in ~/code/dotfiles/scripts for useful things to install/update."
echo "Check debian and linux in ~/Dropbox/notes for useful tips."
