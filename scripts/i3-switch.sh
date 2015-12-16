#!/bin/sh

id=$(i3-msg -t get_tree | i3-get ${1-next})
i3-msg [id="$id"] focus > /dev/null
