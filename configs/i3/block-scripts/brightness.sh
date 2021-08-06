#!/bin/sh

dir=/sys/class/backlight/intel_backlight
[ -e "$dir" ] || exit 1
cur=$(cat $dir/actual_brightness)
max=$(cat $dir/max_brightness)
pct=$(echo "$cur / $max * 100" | bc -l)
if echo "$pct" | grep -qP '^0?.0\d+$'; then
	pct=0.1
fi
printf "Brightness %.1f%%\n" $pct
printf "Brightness %.1f%%\n" $pct
echo "#ffffff"
