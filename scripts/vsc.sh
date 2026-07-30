#!/bin/sh
set -eu

if ! command -v code >/dev/null 2>&1; then
    echo "Visual Studio Code (code) not installed!"
    exit 1
fi

dir=$(realpath "${1-$PWD}")
cd $dir || exit 1

if command -v i3-msg >/dev/null 2>&1; then
    ~/code/dotfiles/scripts/i3-rename-workspace.sh --dir "$dir"
    i3-msg --quiet exec code "$dir"
else
    code "$dir"
fi
