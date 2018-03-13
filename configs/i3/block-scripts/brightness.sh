#!/bin/sh

dir=/sys/class/backlight/intel_backlight
[ -e "$dir" ] || exit 1
cur=$(cat $dir/actual_brightness)
max=$(cat $dir/max_brightness)
pct=$(echo "$cur / $max * 100" | bc -l)
printf "%.1f%%\n" $pct
printf "%.1f%%\n" $pct
echo "#ffffff"
