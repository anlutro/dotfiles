#!/bin/sh

if ! command -v subl 2>&1 > /dev/null; then
	echo "Sublime Text (subl) not installed!"
	exit 1
fi

dir="${1:-.}"
sp=$(find "$dir" -maxdepth 1 -name '*.sublime-project')

if [ -z "$sp" ]; then
	sp="$dir"
fi

subl -n "$sp"
