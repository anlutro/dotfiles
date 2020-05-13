#!/bin/sh
set -eu

url=$(curl -s https://api.github.com/repos/bcicen/acrophone/releases | grep browser_download_url \
    | grep linux-amd64 | head -1 | cut -d\" -f4)
file=$(basename $url)
version=$(echo $url | sed -r 's|.*/download/v([0-9.-]+)/.*|\1|')

if acrophone --version 2>&1 | grep -qF "version $version,"; then
    echo "Latest version ($version) already installed!"
    exit 1
fi

if [ -w /usr/local ]; then
    DIR=/usr/local/bin
else
    DIR="$HOME/bin"
fi

cd ~/downloads || exit 1
wget -nc $url
mv -f $file $DIR/acrophone
chmod +x $DIR/acrophone
