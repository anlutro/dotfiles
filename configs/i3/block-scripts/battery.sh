#!/bin/sh

search='Battery 0: '
text=$(acpi -b | grep "$search" | sed -e "s/$search//" -e "s/, discharging at zero rate - will never fully discharge.//")
status=$(echo $text | cut -d ',' -f 1)

# long/short text
echo $text
echo $text

# color
if [ "$status" = 'Discharging' ]; then
	# percentage-based coloring
	pct=$(echo $text | cut -d ',' -f 2 | sed s/%//)
	if [ $pct -gt 66 ]; then
		# green -> white -- 00ff00 -> ffffff
		hexint=$(echo "255 - ($pct - 67) / 33 * 255" | bc -l)
		hexchar=$(printf '%x' $hexint 2> /dev/null)
		echo "#${hexchar}ff${hexchar}"
	elif [ $pct -gt 33 ]; then
		# white -> yellow -- ffffff -> ffff00
		hexint=$(echo "($pct - 33) / 33 * 255" | bc -l)
		hexchar=$(printf '%x' $hexint 2> /dev/null)
		echo "#ffff${hexchar}"
	else
		# yellow -> red --  ffff00 -> ff0000
		hexint=$(echo "$pct / 33 * 255" | bc -l)
		hexchar=$(printf '%x' $hexint 2> /dev/null)
		echo "#ff${hexchar}00"
	fi
	if [ $pct -lt 5 ]; then
		exit 33
	fi

	# # time-based coloring
	# secs=$(echo $text | cut -d ' ' -f 3 | awk -F: '{ print ($1 * 3600) + ($2 * 60) + $3 }')
	# echo $secs
	# if [ $secs -gt 3600 ]; then
	# 	echo "#ffffff"
	# elif [ $secs -gt 1800 ]; then
	# 	hexint=$(echo "255 - ($secs - 1800) / 1800 * 255" | bc -l)
	# 	hexchar=$(printf '%x' $hexint 2> /dev/null)
	# 	echo "#ffff${hexchar}"
	# else
	# 	hexint=$(echo "$secs / 1800 * 255" | bc -l)
	# 	hexchar=$(printf '%x' $hexint 2> /dev/null)
	# 	echo "#ff${hexchar}00"
	# fi
	# if [ $secs -lt 300 ]; then
	# 	exit 33
	# fi
fi
