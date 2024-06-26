#!/bin/sh

# redirect stdout/stderr from this script to a log file
exec >> "$HOME/.local/share/xorg/xinit.log" 2>&1

# copied from debian. if xhost is installed, use it to give access to the X
# server to any process from the same user on the local host. unlike other
# uses of xhost, this is safe since the kernel can check the actual owner of
# the calling process.
if command -v xhost >/dev/null 2>&1; then
    xhost "+si:localuser:$(id -un)" || true
fi

# copied from manjaro. no clue what practical effects this has
systemctl --user import-environment DISPLAY XAUTHORITY
if command -v dbus-update-activation-environment >/dev/null 2>&1; then
    dbus-update-activation-environment DISPLAY XAUTHORITY
fi

# restart dropbox to let it know it should render the applet
if systemctl --user cat dropbox.service >/dev/null 2>&1; then
    systemctl --user restart dropbox.service &
fi

# allow passing the wm/sm/dm command as args to startx
# TODO: this doesn't actually work!!
X_START_CMD="$*"

# if no argument was passed, try and guess what command to start x with
if [ -z "$X_START_CMD" ]; then
    if command -v 'x-session-manager' >/dev/null 2>&1; then
        X_START_CMD='x-session-manager'
    elif command -v 'x-window-manager' >/dev/null 2>&1; then
        X_START_CMD='x-window-manager'
    elif command -v 'i3' >/dev/null 2>&1; then
        X_START_CMD='i3'
    else
        echo "No appropriate X start command found!"
        exit 1
    fi
fi

# normally you'd prepend ssh-agent to X_START_CMD, which would set all the
# environment variables and make the agent quit when X quits, but because a
# program started from this script (xautolock/xidlehook) needs access to the
# ssh-agent environment variables, use this somewhat nasty hack instead.
# TODO: find alternative solutions
if command -v 'ssh-agent' >/dev/null 2>&1; then
    ssh-agent -k
    eval "$(ssh-agent -s)"
fi

# these scripts have been extracted because for various reasons, at various
# times, I want to re-run them manually after login.
$HOME/.config/xorg/xrandrinit.sh  # configure displays
$HOME/.config/xorg/xprograms.sh   # daemons
$HOME/.config/xorg/xsettings.sh   # keyboard repeat rate, mouse sensitivity...

# start the window manager. this is a blocking command. normally you'd want to
# exec this, but that would prevent the cleanup commands below from running
$X_START_CMD

# when the window manager command quits, we can also kill the ssh-agent
if command -v 'ssh-agent' >/dev/null 2>&1; then
    ssh-agent -k
fi

# kill the gpg-agent if it's running
if command -v gpgconf >/dev/null 2>&1; then
    gpgconf --kill gpg-agent
fi

# prevent programs from trying to communicate with xorg (I think)
if command -v systemctl >/dev/null 2>&1; then
    systemctl --user set-environment DISPLAY= XAUTHORITY=
fi
