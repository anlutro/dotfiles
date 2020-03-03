#!/bin/sh

url=$(curl -s https://api.github.com/repos/docker/compose/releases | grep browser_download_url \
    | grep Linux-x86_64 | grep -v -- '-rc' | head -1 | cut -d\" -f4)
file=$(basename $url)
version=$(echo $url | sed -r 's|.*/download/([0-9.-]+)/.*|\1|')

if docker-compose --version | grep -F "version $version,"; then
    echo "Latest version ($version) already installed!"
    exit 1
fi

if [ -w /usr/local ]; then
    DIR=/usr/local/bin
else
    DIR="$HOME/.local/bin"
fi

cd ~/downloads || exit 1
wget $url
cp $file $DIR/docker-compose
chmod +x $DIR/docker-compose
