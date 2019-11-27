#!/bin/sh
set -eu

url=$(curl -sSL https://www.vagrantup.com/downloads.html | grep -o 'https://.*_x86_64\.deb')
version=$(echo $url | sed -r 's/.*vagrant_([0-9.]+)_x86_64.*/\1/')
filename=$(echo $url | rev | cut -d/ -f 1 | rev)

if [ -z "$url" ]; then
    echo 'Could not find _x86_64.deb!'
    exit 1
fi

if dpkg -s vagrant | grep -q "Version: 1:$version"; then
    echo "Latest version ($version) already installed!"
    exit 0
fi

cd ~/downloads
wget $url
sudo dpkg -i $filename
rm -f $filename
