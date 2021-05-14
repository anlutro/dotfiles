#!/bin/sh

dir="$(dirname "$(readlink -f "$0")")"
id="$(i3-msg -t get_tree | $dir/i3-get.py "${1-next}")"
[ $? = 0 ] && [ "$id" ] && i3-msg [id="$id"] focus >/dev/null
