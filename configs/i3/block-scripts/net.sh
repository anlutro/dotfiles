#!/bin/sh

if [ -n "$1" ]; then
	iface_name=$1
else
	iface_name=$(ip route | grep default | cut -d ' ' -f 5)
fi

if [ -n "$2" ]; then
	addr_name=$2
else
	addr_name='inet '
fi

ip_addr=$(ip addr show $iface_name | grep 'inet ' | cut -d ' ' -f 8)

if echo $iface_name | grep wlan > /dev/null; then
	is_wifi=1
	quality=$(grep $iface_name /proc/net/wireless | awk '{ print int($3 * 100 / 70) }')
	text="$iface_name $ip_addr ($quality%)"
else
	text="$iface_name $ip_addr"
fi

# long/short text
echo "$text"
echo "$text"

# color
if [ $ip_addr = 'down' ]; then
	echo "#CC0000"
elif [ $is_wifi = 1 ]; then
	if [ $quality -ge 80 ]; then
	    echo "#00FF00"
	elif [ $quality -lt 80 ]; then
	    echo "#FFF600"
	elif [ $quality -lt 60 ]; then
	    echo "#FFAE00"
	elif [ $quality -lt 40 ]; then
	    echo "#FF0000"
	fi
else
	echo "#00CC00"
fi
