#!/bin/sh

confirm() {
    echo -n "$* [Y/n] "
    read REPLY
    if [ -z "$REPLY" ] || [ "$REPLY" != "${REPLY#[Yy]}" ]; then
        return 0
    fi
    return 1
}

# programs I need/want everywhere
pacman -Sy \
    strace htop iotop mtr \
    ranger tree \
    unzip jq bc ripgrep \
    vim fzf bash-completion
systemctl enable --now systemd-timesyncd.service

if confirm "install networkmanager?"; then
    pacman -Sy networkmanager
    systemctl enable --now NetworkManager.service
fi

if confirm "install xorg/desktop programs?"; then
    # xorg / desktop utils
    pacman -Sy \
        xorg-{xserver-xinit,xrandr,xsetroot,xset,setxkbmap,xinput} \
        i3-wm i3lock i3blocks xclip rofi dunst scrot feh \
        rxvt-unicode redshift pipewire-pulse pamixer \
        adobe-source-code-pro-fonts ttf-droid
    systemctl disable --now geoclue

    if confirm "install bluetooth tools?"; then
        pacman -Sy bluez bluez-utils
    fi

    if confirm "install sublime text?"; then
        if ! pacman-key -l 8A8F901B >/dev/null 2>&1; then
            curl -O https://download.sublimetext.com/sublimehq-pub.gpg
            pacman-key --add sublimehq-pub.gpg
            pacman-key --lsign-key 8A8F901A
            rm sublimehq-pub.gpg
        fi
        if ! pacman-conf -r sublime-text >/dev/null 2>&1; then
            echo "
[sublime-text]
Server = https://download.sublimetext.com/arch/dev/x86_64" >> /etc/pacman.conf
        fi
        pacman -Syu sublime-text
    fi
fi

echo
echo "Finished! Note that some packages have been left out:"
echo "  * Intel drivers (in case of Nvidia): xf86-video-intel libva-intel-driver intel-media-driver"
echo "  * xorg input driver: xf86-input-libinput or xf86-input-synaptics"
