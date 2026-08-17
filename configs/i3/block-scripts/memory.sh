#!/bin/bash
meminfo=$(cat /proc/meminfo | grep ^Mem)
mem_total=$(echo "$meminfo" | grep MemTotal | awk '{print $2}')
mem_available=$(echo "$meminfo" | grep MemAvailable | awk '{print $2}')
mem_available_gb=$(echo "scale=1; $mem_available / 1024 / 1024" | bc -l)
pct="$(echo "($mem_total - $mem_available) / $mem_total * 100" | bc -l)"
pct_int=$(printf "%.0f" $pct)

if [ $pct_int -lt 20 ]; then
    pbar="▱▱▱▱"
elif [ $pct_int -lt 40 ]; then
    pbar="▰▱▱▱"
elif [ $pct_int -lt 60 ]; then
    pbar="▰▰▱▱"
elif [ $pct_int -lt 80 ]; then
    pbar="▰▰▰▱"
else
    pbar="▰▰▰▰"
fi

echo "Memory ${pbar} ${mem_available_gb}G"
echo "Memory ${pbar} ${mem_available_gb}G $pct_int%"
if [ $pct_int -gt 80 ]; then
    # yellow -> red --  ffff00 -> ff0000
    hexint=$(echo "(100 - $pct_int) / 20 * 255" | bc -l)
    hexchar=$(printf '%02x' $hexint 2> /dev/null)
    echo "#ff${hexchar}00"
elif [ $pct_int -gt 60 ]; then
    # white -> yellow -- ffffff -> ffff00
    hexint=$(echo "(80 - $pct_int) / 20 * 255" | bc -l)
    hexchar=$(printf '%02x' $hexint 2> /dev/null)
    echo "#ffff${hexchar}"
else
    echo "#ffffff"
fi
