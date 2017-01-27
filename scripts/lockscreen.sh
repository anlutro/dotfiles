#!/bin/sh

cmd='i3lock -c 000000'

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
