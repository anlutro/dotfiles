#!/bin/sh

id=$(i3-msg -t get_tree | i3-get ${1-next})
[ $? = 0 ] && [ "$id" ] && i3-msg [id="$id"] focus
