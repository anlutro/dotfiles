#!/bin/sh

for try_dir in intel_backlight acpi_video0 amdgpu_bl0; do
    if [ -e "/sys/class/backlight/$try_dir" ]; then
        dir="/sys/class/backlight/$try_dir"
        break
    fi
done
if [ -z "$dir" ]; then exit 1; fi

cur="$(cat "$dir/actual_brightness")"
max="$(cat "$dir/max_brightness")"
pct="$(echo "$cur / $max * 100" | bc -l)"
if echo "$pct" | grep -qP '^0?.0\d+$'; then
    pct=0.1
fi
printf "Brightness %.1f%%\n" $pct
printf "Brightness %.1f%%\n" $pct
echo "#ffffff"
