#!/bin/sh
set -eu
# shellcheck source=_lib.sh
. "$(dirname "$(readlink -f "$0")")/_lib.sh"

url=$(curl -sSL https://www.vagrantup.com/downloads.html | grep -oP 'https://[/A-z0-9._-]+_x86_64\.deb' | sort -V | tail -1)
version=$(echo $url | sed -r 's/.*vagrant_([0-9.]+)_x86_64.*/\1/')

if [ -z "$url" ]; then
    fail 'Could not find _x86_64.deb!'
fi

if dpkg -s vagrant | grep -q "Version: 1:$version"; then
	latest_already_installed
fi

filename=$(download $url)
sudo dpkg -i $filename
rm -f $filename
