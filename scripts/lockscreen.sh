#!/bin/sh
set -eu

# call /bin/true just to make it easier to chain commands.
# in python I'd just do cmds = [...] and ' && '.join(cmds)
# but this is bash, so...
cmd='true'

# delete keys from ssh agent if it is running
if [ -n "${SSH_AGENT_PID-}" ]; then
    cmd="$cmd && ssh-add -D"
fi

# delete keys from gpg agent if it is running
if pidof gpg-agent > /dev/null; then
    cmd="$cmd && gpgconf --reload gpg-agent"
fi

# if i3lock is already running, trying to execute it again will fail.
# the result is that the computer won't suspend through xautolock if
# the machine has been manually locked (but not suspended) before.
if ! pidof i3lock > /dev/null; then
    rm -f /tmp/lock.png
    # we need `magick` to blur or pixelize screenshots
    if ! command -v magick >/dev/null 2>&1; then
        true  # do nothing
    elif command -v maim >/dev/null 2>&1; then
        maim /tmp/lock.bmp
    elif command -v scrot >/dev/null 2>&1; then
        scrot /tmp/lock.bmp
    fi

    if [ -e /tmp/lock.bmp ]; then
        magick /tmp/lock.bmp -scale 10% -scale 1000% /tmp/lock.png  # pixelization
        # magick /tmp/lock.bmp -blur 0x5 /tmp/lock.png  # blurring
        rm /tmp/lock.bmp
        cmd="$cmd && i3lock -i /tmp/lock.png && rm /tmp/lock.*"
    else
        cmd="$cmd && i3lock -c 000000"
    fi
fi

while [ $# -gt 0 ]; do
    case $1 in
        -- )
            break 2
            ;;
        -s|--suspend )
            cmd="$cmd && systemctl suspend"
            ;;
        * )
            echo "Uknown argument: $1" >&2
            exit 1
            ;;
    esac
    shift
done

eval $cmd
