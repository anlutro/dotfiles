#!/bin/sh

for try_dir in intel_backlight acpi_video0 amdgpu_bl0; do
    if [ -e "/sys/class/backlight/$try_dir" ]; then
        dir="/sys/class/backlight/$try_dir"
        break
    fi
done
if [ -z "$dir" ]; then exit 1; fi

emoji="🔆"
cur="$(cat "$dir/actual_brightness")"
max="$(cat "$dir/max_brightness")"
pct="$(echo "$cur / $max * 100" | bc -l)"
pct_int=$(printf "%d" $pct)
if echo "$pct" | grep -qP '^0?.0\d+$'; then
    pct=0.1
fi
# if [ ${pct%.*} -lt 5 ]; then
#     emoji="🌙"
# fi

if [ $pct_int -lt 5 ]; then
    pbar="▱▱▱▱▱"
elif [ $pct_int -lt 10 ]; then
    pbar="▰▱▱▱▱"
elif [ $pct_int -lt 20 ]; then
    pbar="▰▰▱▱▱"
elif [ $pct_int -lt 40 ]; then
    pbar="▰▰▰▱▱"
elif [ $pct_int -lt 80 ]; then
    pbar="▰▰▰▰▱"
else
    pbar="▰▰▰▰▰"
fi

echo "${emoji}${pbar}"
printf "%.1f%%\n" $pct
echo "#ffffff"
