#!/bin/bash

# wrapper script that normalizes command-line arguments to various terminal emulators

shopt -s extglob

workdir="$PWD"
while [ $# -gt 0 ]; do
    case "$1" in
        --term?(=*) )
            [[ "$1" = *=* ]] || shift
            term=$(echo "$1" | cut -d= -f2)
            ;;
        -w?(=*)|--working-directory?(=*) )
            [[ "$1" = *=* ]] || shift
            workdir=$(echo "$1" | cut -d= -f2)
            ;;
        --x11-instance )
            [[ "$1" = *=* ]] || shift
            x11_instance=$(echo "$1" | cut -d= -f2)
            ;;
        -* )
            echo "unknown option: $1" >&2
            exit 1
            ;;
        * )
            if [ -z "${command-}" ]; then
                command=("$@")
                break
            fi
            ;;
    esac
    shift
done

if [ -z "$term" ]; then
    for try_term in alacritty rxvt-unicode urxvt; do
        if which $try_term >/dev/null 2>&1; then
            term="$try_term"
            break
        fi
    done
fi
if [ -z "$term" ]; then
    echo "don't know which terminal emulator to use!" >&2
    exit 1
fi

args=()
if [ $term = alacritty ]; then
    [ -n "$x11_instance" ] && args+=(--class "$x11_instance")
    [ -n "$workdir" ] && args+=(--working-directory "$workdir")
elif [ $term = rxvt-unicode ] || [ $term = urxvt ]; then
    [ -n "$x11_instance" ] && args+=(-name "$x11_instance")
    [ -n "$workdir" ] && args+=(-cd "$workdir")
fi
# alacritty expects this to be the final cli flag
if [ -n "${command-}" ]; then
    args+=(-e "${command[@]}")
fi

# echo $term "${args[@]}" >&2
exec $term "${args[@]}"
