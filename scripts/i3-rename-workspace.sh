#!/bin/sh
cur_ws=$(i3-msg -t get_workspaces | jq '.[] | select(.focused==true).name' | cut -d\" -f2)
new_name=$(echo $cur_ws | rofi -dmenu -lines 1 -p 'Rename workspace to: ')
if [ -n "$new_name" ]; then
	echo "Renaming workspace to $new_name"
	i3-msg rename workspace to "$new_name"
fi
