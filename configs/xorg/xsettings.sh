#!/bin/sh

cmd_exists() {
    for cmd in "$@"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            return 1
        fi
    done
    return 0
}

# load .Xdefaults and .Xresources if they are present
# note that system-wide files are ignored!
if cmd_exists xrdb; then
    if [ -e $HOME/.Xdefaults ]; then
        xrdb $HOME/.Xdefaults
    fi
    if [ -e $HOME/.Xresources ]; then
        xrdb -merge $HOME/.Xresources
    fi
fi

# update directories from ~/.config/user-dirs.dirs
if cmd_exists xdg-user-dirs-update; then
    xdg-user-dirs-update
fi

# x settings
if cmd_exists xset; then
    # turn on/off system beep
    xset b off

    # keyboard repeat - delay (ms) and characters per second
    xset r rate 175 35

    # mouse acceleration - accel ratio and threshold
    xset m 1/1 0

    # blank screen after 600 seconds
    xset s 600 600

    # standby/suspend/turn off screen after N seconds
    xset dpms 900 1200 1800
fi

# keyboard mapping options
if cmd_exists setxkbmap; then
    # default options, applies to all currently connected keyboards
    setxkbmap -option compose:ralt -option caps:super
fi

# touchpad settings
if cmd_exists xinput; then
    touchpad_ids=$(xinput list | grep 'Touchpad' | sed -r 's/.*id=([0-9]+).*/\1/')
    for device_id in $touchpad_ids; do
        # disable middle click for touchpads
        xinput set-button-map $device_id 1 0 3 4 5 6 7
        xinput set-prop $device_id 'Synaptics Tap Action' 1 1 1 1 1 0 0
        xinput set-prop $device_id 'Synaptics Tap Durations' 100 100 100
    done
fi

# for apple keyboards, put the ~ key in the correct spot, and swap alt with super
if cmd_exists setxkbmap xinput; then
    apple_kbd_ids=$(xinput list | grep 'Apple.*Keyboard' | sed -r 's/.*id=([0-9]+).*/\1/')
    for device_id in $apple_kbd_ids; do
        setxkbmap -device $device_id -option apple:badmap -option altwin:swap_alt_win
    done
fi

if cmd_exists synclient && grep -Eiq 'synap|alps|etps' /proc/bus/input/devices; then
    synclient AccelFactor=0 MinSpeed=1.75 MaxSpeed=3.5
    # tapping the touchpad sends a mouse button 1 event
    synclient TapButton1=1
    # stop scrolling immediately when lifting fingers
    synclient CoastingSpeed=0
fi

if [ ! -x $HOME/.fehbg ]; then
    xsetroot -solid '#222222'
fi
