#!/bin/sh

loadavg="$(cut -d ' ' -f1 /proc/loadavg)"
loadavg_int=$(printf "%d" $loadavg)
cpus="$(nproc)"

for i in $(seq 1 $((cpus / 2))); do
    if [ $loadavg_int -gt $i ]; then
        pbar="${pbar}▰"
    else
        pbar="${pbar}▱"
    fi
done

# full text
echo "Load $pbar $loadavg"

# short text
echo "Load $pbar $loadavg"

# color if load is too high
awk -v cpus=$cpus -v loadavg=$loadavg 'BEGIN {
    pct=int(loadavg / cpus / 1.5 * 100)
    if (pct > 85) {
        print "#ff0000"
    }
    else if (pct > 60) {
        # yellow -> red -- ffff00 -> ff0000
        hexint = 255 - (pct - 60) / 25 * 255
        printf "#ff%02x00\n", hexint
    }
    else if (pct > 35) {
        # white -> yellow -- ffffff -> ffff00
        hexint = 255 - (pct - 35) / 25 * 255
        printf "#ffff%02x\n", hexint
    }
    else {
        print "#ffffff"
    }
}'
