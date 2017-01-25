#!/bin/sh

loadavg="$(cut -d ' ' -f1 /proc/loadavg)"
cpus="$(nproc)"

# full text
echo "$loadavg"

# short text
echo "$loadavg"

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
