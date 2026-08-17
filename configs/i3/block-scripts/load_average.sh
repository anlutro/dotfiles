#!/bin/sh

loadavg="$(cut -d ' ' -f1 /proc/loadavg)"
loadavg_int=$(printf "%.0f" $loadavg)
cpus="$(nproc)"

for i in $(seq 1 2 $cpus); do
    if [ $loadavg_int -gt $i ]; then
        pbar="${pbar}▰"
    else
        pbar="${pbar}▱"
    fi
done

# full text
echo "$loadavg $pbar load"

# short text
echo "$loadavg $pbar load"

# color if load is too high
awk -v cpus=$cpus -v loadavg=$loadavg 'BEGIN {
    ratio=loadavg / cpus
    if (ratio > 1) {
        print "#ff3300"
    }
    else if (ratio > 0.75) {
        # yellow -> red -- ffff00 -> ff0000
        hexint = 255 - (ratio - 0.75) / 0.50 * 255
        printf "#ff%02x00\n", hexint
    }
    else if (ratio > 0.25) {
        # white -> yellow -- ffffff -> ffff00
        hexint = 255 - (ratio - 0.25) / 0.50 * 255
        printf "#ffff%02x\n", hexint
    }
    else {
        print "#ffffff"
    }
}'
