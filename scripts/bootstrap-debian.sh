#!/bin/bash
set -eu

confirm() {
    read -rp "$* [Y/n] "
    if [ -z "$REPLY" ] || [[ "$REPLY" =~ ^[Yy] ]]; then
        return 0
    fi
    return 1
}

# common variables
debian_release=$(lsb_release -cs)

# make sure contrib and non-free components are enabled, add backports repo
debian_mirror=$(grep -oP 'http.*ftp.*debian\.org' /etc/apt/sources.list | sort | uniq)
sed -ri "s/(.* $debian_release main)$/\1 contrib non-free/g" /etc/apt/sources.list
mkdir -p /etc/apt/sources.list.d
cat <<EOF > /etc/apt/sources.list.d/backports.list
deb $debian_mirror/debian/ $debian_release-backports main
deb-src $debian_mirror/debian/ $debian_release-backports main
EOF

# don't install recommended packages by default
echo 'apt::install-recommends "false";' > /etc/apt/apt.conf.d/99-install-recommends

apt-get update && apt-get dist-upgrade -y
apt-get install -y git vim tree curl irssi zip unzip fuse psmisc jq bc \
    silversearcher-ag policykit-1 sudo apt-transport-https htop gpg

usermod -a -G sudo,root,adm,staff,systemd-journal andreas

if confirm "Install Xorg, i3 and utilities?"; then
    apt-get install -y xserver-xorg-{core,input-{kbd,mouse,evdev}} x11-xserver-utils \
        dbus-x11 xclip rofi dunst libnotify-bin scrot imagemagick xdg-user-dirs \
        feh rxvt-unicode-256color i3-wm i3lock i3blocks xinit xautolock \
        alsa-utils ntfs-3g redshift dmz-cursor-theme

    update-alternatives --set x-cursor-theme /usr/share/icons/DMZ-White/cursor.theme
    mv /etc/fonts/conf.d/??-user.conf /etc/fonts/conf.d/98-user.conf
    mv /etc/fonts/conf.d/??-local.conf /etc/fonts/conf.d/99-local.conf

    if confirm "Install laptop utilities?"; then
        apt-get install -y pm-utils xbacklight acpi acpi-call-dkms network-manager tlp
    fi

    if confirm "Install MS TrueType fonts?"; then
        apt-get install -y ttf-mscorefonts-installer
    fi

    if confirm "Install Sublime Text?"; then
        curl -fsSL https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor \
            > /etc/apt/trusted.gpg.d/sublimetext.gpg
        echo "deb https://download.sublimetext.com/ apt/dev/" \
            > /etc/apt/sources.list.d/sublime-text.list
        apt-get update && apt-get install -y sublime-text
    fi
fi

if confirm "Install Dropbox?"; then
    file=$(curl -s https://linux.dropbox.com/packages/debian/ | \
        grep -oP 'href="dropbox_\d{4}.*amd64.deb"' | cut -d\" -f2 | sort | tail -1)
    wget -nv https://linux.dropbox.com/packages/debian/$file
    apt install $file
    rm $file
fi

if confirm "Install Docker?"; then
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor \
        > /etc/apt/trusted.gpg.d/docker.gpg
    echo "deb [arch=amd64] https://download.docker.com/linux/debian $debian_release stable" \
        > /etc/apt/sources.list.d/docker.list
    apt-get update && apt-get install -y docker-ce
    usermod -a -G docker andreas
fi

echo
echo "Finished! Note that some packages have been left out:"
echo "  * xserver-xorg-video-intel (in case you're using nvidia)"
echo "  * xserver-xorg-input-synaptics (in case you want to use libinput)"
echo "  * chromium (in case you want to get chrome instead)"
echo "Look in ~/code/dotfiles/scripts for useful things to install/update."
echo "Check debian and linux in ~/Dropbox/notes for useful tips."
