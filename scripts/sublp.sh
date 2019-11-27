#!/bin/sh

if ! command -v subl >/dev/null 2>&1; then
    echo "Sublime Text (subl) not installed!"
    exit 1
fi

dir="${1:-.}"
cd $dir || exit 1

sp=$(find "$dir" -maxdepth 1 -name '*.sublime-project')
if [ -z "$sp" ]; then
    echo "No sublime-project found, running init-project ..."
    init-project --noninteractive --allow-no-type
    sp=$(find "$dir" -maxdepth 1 -name '*.sublime-project')
fi

if [ -z "$sp" ]; then
    sp="$dir"
fi

subl -n "$sp"
