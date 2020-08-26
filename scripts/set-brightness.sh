#!/bin/sh
set -eu

smart_modifier=

if [ "$(find /sys/class/backlight/ -mindepth 1 -maxdepth 1 | wc -l)" -lt 1 ]; then
    echo "Couldn't find anything in /sys/class/backlight!"
    exit 1
fi

if [ "$1" = 'up' ] || [ "$1" = 'down' ]; then
    smart_modifier="$1"
else
    if ! echo "$1" | grep -Pqx '[-+]?[0-9]+%?'; then
        echo "Unknown format! Usage examples:"
        echo "set-brightness [ 1 | 50% | +100 | +25% | up | down ]"
        exit 1
    fi

    if echo "$1" | grep -Pq '%$'; then
        if echo "$1" | grep -Pq '^[-+]'; then
            modifier_p=$(echo "$1" | grep -o '[-+][0-9]*')
        else
            new_brightness_p=$(echo "$1" | grep -o '[0-9]*')
        fi
    else
        if echo "$1" | grep -Pq '^[-+]'; then
            modifier=$(echo "$1" | grep -o '[-+][0-9.]*')
        else
            new_brightness="$1"
        fi
    fi
fi

for dir in $(find /sys/class/backlight/ -mindepth 1 -maxdepth 1); do
    name=$(basename "$dir")
    old_brightness=$(cat "$dir/brightness")
    max_brightness=$(cat "$dir/max_brightness")
    max_mod=$(( max_brightness / 7 ))
    min_mod=$(( max_brightness / 100 ))

    if [ "$smart_modifier" = 'up' ]; then
        modifier="+$(( $old_brightness ))"
    elif [ "$smart_modifier" = 'down' ]; then
        modifier="-$(( $old_brightness / 2 ))"
    fi

    if [ -n "${modifier_p-}" ]; then
        old_brightness_p=$(( 100 * $old_brightness / $max_brightness ))
        new_brightness_p=$(( $old_brightness_p $modifier_p ))
    elif [ -n "${modifier-}" ]; then
        op=$(echo $modifier | grep -o '^[-+]')
        modifier=$(echo $modifier | grep -o '[0-9]*$')
        if [ -n "$smart_modifier" ]; then
            modifier=$(( $modifier > $max_mod ? $max_mod : $modifier ))
            modifier=$(( $modifier < $min_mod ? $min_mod : $modifier ))
        fi
        new_brightness=$(( $old_brightness $op $modifier ))
    fi
    if [ -n "${new_brightness_p-}" ]; then
        new_brightness=$(( $max_brightness * $new_brightness_p / 100 ))
    fi

    if [ $new_brightness -gt $max_brightness ]; then
        new_brightness=$max_brightness
    elif [ $new_brightness -lt 1 ]; then
        new_brightness=1
    fi

    echo "New brightness for $name: $new_brightness"

    if [ -w "$dir/brightness" ]; then
        steps=10
        for i in $(seq $steps); do
            if [ $new_brightness -gt $old_brightness ]; then
                op=+
                diff=$(( new_brightness - old_brightness ))
            else
                op=-
                diff=$(( old_brightness - new_brightness ))
            fi
            echo $(( old_brightness $op (diff * i / steps) )) > "$dir/brightness"
            sleep 0.01
        done
    else
        echo "$dir/brightness not writable, consider adding udev rule and adding yourself to the 'video' group:"
        echo '  SUBSYSTEM=="backlight", ACTION=="add", RUN+="/bin/chgrp video /sys/class/backlight/%k/brightness", RUN+="/bin/chmod g+w /sys/class/backlight/%k/brightness"'
        if [ -n "$PS1" ]; then
            echo "Using sudo for now:"
            sudo sh -c "echo '$new_brightness' > '$dir/brightness'"
        else
            exit 1
        fi
    fi
done
