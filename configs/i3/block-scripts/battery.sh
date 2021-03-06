#!/bin/sh

warn_state_file=/tmp/.battery-warning-sent
search='Battery 0: '
full_text=$(acpi -b | grep "^$search" | cut -d: -f2-)
status=$(echo "$full_text" | cut -d, -f1 | tr -d '[:space:]')
pct=$(echo "$full_text" | cut -d, -f2 | sed s/%// | tr -d '[:space:]')
if ! echo "$full_text" | grep -qF 'rate information unavailable'; then
    remaining=$(echo "$full_text" | cut -d, -f3 | cut -d' ' -f2)
fi

if [ "$status" = 'Unknown' ]; then
    status="Full"
fi
text="$status $pct%"
if [ -n "${remaining-}" ]; then
    text="$text $remaining"
fi

# long/short text
echo "$text"
echo "$text"

# color
if [ "$status" = 'Charging' ]; then
    if [ $pct -gt 90 ]; then
        # green -> white -- 00ff00 -> ffffff
        hexint=$(echo "255 - ($pct - 90) / 10 * 255" | bc -l)
        hexchar=$(printf '%02x' $hexint 2> /dev/null)
        echo "#${hexchar}ff${hexchar}"
    fi
    rm -f $warn_state_file
else
    # percentage-based coloring
    if [ $pct -gt 66 ]; then
        # green -> white -- 00ff00 -> ffffff
        hexint=$(echo "255 - ($pct - 67) / 33 * 255" | bc -l)
        hexchar=$(printf '%02x' $hexint 2> /dev/null)
        echo "#${hexchar}ff${hexchar}"
    elif [ $pct -gt 33 ]; then
        # white -> yellow -- ffffff -> ffff00
        hexint=$(echo "($pct - 33) / 33 * 255" | bc -l)
        hexchar=$(printf '%02x' $hexint 2> /dev/null)
        echo "#ffff${hexchar}"
    else
        # yellow -> red --  ffff00 -> ff0000
        hexint=$(echo "$pct / 33 * 255" | bc -l)
        hexchar=$(printf '%02x' $hexint 2> /dev/null)
        echo "#ff${hexchar}00"
    fi

    # # time-based coloring
    # secs=$(echo $text | cut -d ' ' -f 3 | awk -F: '{ print ($1 * 3600) + ($2 * 60) + $3 }')
    # echo $secs
    # if [ $secs -gt 3600 ]; then
    #     echo "#ffffff"
    # elif [ $secs -gt 1800 ]; then
    #     hexint=$(echo "255 - ($secs - 1800) / 1800 * 255" | bc -l)
    #     hexchar=$(printf '%02x' $hexint 2> /dev/null)
    #     echo "#ffff${hexchar}"
    # else
    #     hexint=$(echo "$secs / 1800 * 255" | bc -l)
    #     hexchar=$(printf '%02x' $hexint 2> /dev/null)
    #     echo "#ff${hexchar}00"
    # fi
    # if [ $secs -lt 300 ]; then
    #     exit 33
    # fi

    if command -v notify-send >/dev/null 2>&1; then
        if [ $pct -lt 5 ]; then
            if [ ! -e $warn_state_file ]; then
                notify-send --urgency=critical 'Battery warning' "Battery level: $pct%"
                touch $warn_state_file
            fi
        elif [ $pct -gt 10 ]; then
            rm -f $warn_state_file
        fi
    fi
fi
