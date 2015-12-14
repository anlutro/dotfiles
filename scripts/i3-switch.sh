#!/bin/sh

id=$(i3-get ${1-next})
i3-msg [id="$id"] focus > /dev/null
