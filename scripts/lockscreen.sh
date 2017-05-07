#!/bin/sh

cmd='true'

# if i3lock is already running, trying to execute it again will fail.
# the result is that the computer won't suspend through xautolock if
# the machine has been manually locked (but not suspended) before.
if ! pidof i3lock > /dev/null; then
	cmd="$cmd && i3lock -c 000000"
fi

# delete keys from ssh agent if it is running
if [ -n "$SSH_AGENT_PID" ]; then
	cmd="$cmd && ssh-add -D"
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
