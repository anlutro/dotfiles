#!/bin/sh
set -eu

cur_name=$(i3-msg -t get_workspaces | jq -r '.[] | select (.focused==true).name')
cur_num=$(echo $cur_name | grep -oP '^[0-9]+')
if echo "$cur_name" | grep -qP '^[0-9]+:'; then
	cur_name="$(echo $cur_name | cut -d: -f2)"
fi

if [ "${1-}" = "-d" ] || [ "${1-}" = "--dir" ]; then
	shift
	dir="${1-$PWD}"
	new_name=$(basename $dir)
elif [ $# -gt 0 ]; then
	new_name="$*"
else
	new_name=$(rofi -m -4 -dmenu -input /dev/null -lines 1 -p 'rename/renumber workspace to')
fi

if [ "$cur_name" = "$cur_num" ] && echo "$new_name" | grep -qxP '[0-9]+'; then
	new_name="$new_name"
elif echo "$new_name" | grep -qxP '[0-9]+'; then
	new_name="$new_name:$cur_name"
elif ! echo "$new_name" | grep -qP '^[0-9]+:'; then
	new_name="$cur_num:$new_name"
fi

if [ -n "$new_name" ]; then
    echo "Renaming workspace to $new_name"
    i3-msg --quiet rename workspace to "$new_name"
fi
