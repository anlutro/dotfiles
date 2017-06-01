#!/bin/sh

if [ -n "$1" ]; then
	iface_name=$1
else
	iface_name=$(ip route | grep -oP 'dev e[\w\d]+' | cut -d ' ' -f 2 | sort | uniq)
	if [ -z "$iface_name" ]; then
		exit
	fi
fi

if [ -n "$2" ]; then
	addr_name=$2
else
	addr_name='inet '
fi

ip_addr=$(ip addr show $iface_name | grep "$addr_name" | cut -d ' ' -f 6 | cut -d '/' -f 1)
text="$iface_name $ip_addr"

# long/short text
echo "$text"
echo "$text"

# color - green/yellow/red based on percentage
if [ "$ip_addr" = 'down' ]; then
	echo "#ff3333"
else
	echo "#00ff00"
fi
