#!/bin/sh

cmd='i3lock -c 000000'

while test $# -gt 0; do
	case $1 in
		-- )
			break 2
			;;
		-s|--suspend )
			cmd="$cmd && systemctl suspend"
			;;
		* )
			echo "Uknown argument: $1" >2&
			exit 1
			;;
	esac
	shift
done

$cmd
