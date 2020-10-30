#!/bin/sh

# checks if a command exist, and that it's not already running
check_cmd() {
    command -v $1 >/dev/null 2>&1 && ! pidof $1 >/dev/null
}

# displays simple notifications
if check_cmd dunst; then
    dunst &
fi

# xflux/redshift change the screen's color when night time comes around
if check_cmd redshift; then
    redshift -t 6500:2900 &
fi

# network-manager applet, puts a network icon in the tray
if check_cmd nm-applet; then
    nm-applet &
fi

# unclutter removes the mouse cursor after a given amount of idle time
if check_cmd unclutter; then
    unclutter -idle 3 -root &
fi

# auto lock/suspend after inactivity
# if command -v xidlehook >/dev/null 2>&1; then
#     xidlehook --not-when-fullscreen --not-when-audio --timer 300 'lockscreen' '' --timer 1800 'lockscreen --suspend' '' &
# elif command -v xautolock >/dev/null 2>&1; then
#     if acpi -b 2> /dev/null | grep -q Battery; then
#         xautolock -time 60 -corners 000- -cornersize 30 -detectsleep -locker 'lockscreen --suspend' &
#     else
#         xautolock -time 5 -locker 'lockscreen' &
#     fi
# fi
