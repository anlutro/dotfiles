#!/bin/sh

dir="${1:-.}"
sp=$(find "$dir" -maxdepth 1 -name '*.sublime-project')

if [ -z "$sp" ]; then
	sp="$dir"
fi

subl -n "$sp"
