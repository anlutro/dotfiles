#!/bin/sh -eu

cur_name=$(i3-msg -t get_workspaces | jq -r '.[] | select (.focused==true).name')
cur_num=$(echo $cur_name | grep -oP '^[0-9]+')

if [ "${1-}" = "-d" ] || [ "${1-}" = "--dir" ]; then
	shift
	dir="${1-$PWD}"
	new_name=$(basename $dir)
elif [ $# -gt 0 ]; then
	new_name="$*"
else
	new_name=$(rofi -m -4 -dmenu -input /dev/null -lines 1 -p 'Rename workspace to')
fi

if ! echo "$new_name" | grep -qP '^[0-9]+:'; then
	new_name="$cur_num:$new_name"
fi

if [ -n "$new_name" ]; then
    echo "Renaming workspace to $new_name"
    i3-msg rename workspace to "$new_name"
fi
