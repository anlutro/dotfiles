#!/bin/sh -eu

max_step=20
cur_brightness="$(xbacklight -get)"
cur_brightness_int="$(perl -MPOSIX -e "print ceil($cur_brightness)")"

if [ "$1" = 'up' ] || [ "$1" = '+1' ]; then
    new_brightness=$(echo "$cur_brightness_int * 2" | bc)
    if [ "$(echo $new_brightness - $cur_brightness_int | bc)" -gt $max_step ]; then
        new_brightness=$(echo "$cur_brightness_int + $max_step" | bc)
    fi
elif [ "$1" = 'down' ] || [ "$1" = '-1' ]; then
    new_brightness=$(echo "$cur_brightness_int / 2" | bc)
    if [ "$(echo $cur_brightness_int - $new_brightness | bc)" -gt $max_step ]; then
        new_brightness=$(echo "$cur_brightness_int - $max_step" | bc)
    fi
else
    echo "unknown arg: $1 - choose between up/+1 or down/-1"
    exit 1
fi

new_brightness_int=$(echo "$new_brightness" | cut -d. -f1)

if [ "$new_brightness_int" -gt 100 ]; then
    new_brightness=100
elif [ "$new_brightness_int" -lt 1 ]; then
    new_brightness=1
fi

xbacklight -set "$new_brightness"
