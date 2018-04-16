#!/bin/sh

new_name=$(rofi -dmenu -input /dev/null -lines 1 -p 'Rename workspace to: ')

if [ -n "$new_name" ]; then
	echo "Renaming workspace to $new_name"
	i3-msg rename workspace to "$new_name"
fi
