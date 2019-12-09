#!/bin/sh

if [ "$(find /sys/class/backlight/ -mindepth 1 -maxdepth 1 | wc -l)" -lt 1 ]; then
    echo "Couldn't find anything in /sys/class/backlight!"
    exit 1
fi

if ! echo "$1" | grep -Pqx '[-+]?[0-9]+%?'; then
    echo "Unknown format! Usage examples:"
    echo "set-brightness 1"
    echo "set-brightness 50%"
    echo "set-brightness +100"
    echo "set-brightness +25%"
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

for dir in $(find /sys/class/backlight/ -mindepth 1 -maxdepth 1); do
    old_brightness=$(cat $dir/brightness)
    max_brightness=$(cat $dir/max_brightness)

    if [ -n "$modifier_p" ]; then
        old_brightness_p=$(echo "100 * $old_brightness / $max_brightness" | bc -l)
        new_brightness_p=$(echo "$old_brightness_p $modifier_p" | bc -l)
    elif [ -n "$modifier" ]; then
        new_brightness=$(echo "$old_brightness + $modifier" | bc -l)
    fi
    if [ -n "$new_brightness_p" ]; then
        new_brightness=$(echo "$max_brightness * $new_brightness_p / 100" | bc)
    fi

    if [ $new_brightness -gt $max_brightness ]; then
        new_brightness=$max_brightness
    elif [ $new_brightness -lt 1 ]; then
        new_brightness=1
    fi

    echo "new_brightness=$new_brightness"

    if [ -w $dir/brightness ]; then
        echo $new_brightness > $dir/brightness
    else
        echo "$dir/brightness is not writable, using sudo"
        sudo sh -c "echo $new_brightness > $dir/brightness"
    fi
done
