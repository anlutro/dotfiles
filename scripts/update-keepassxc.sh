#!/bin/sh

url=$(
    curl -s https://api.github.com/repos/keepassxreboot/keepassxc/releases | \
    grep browser_download_url | grep -P '\/[\d\.]+\/' | grep \.AppImage | \
    head -1 | cut -d\" -f4
)
file=$(basename $url)
version=$(echo $file | grep -oP '\d[\d.]{2,}\d')

if command -v keepassxc-cli >/dev/null 2>&1; then
    installed_version=$(keepassxc-cli --version | grep -oP '[\d.]{3,}')
elif command -v keepassxc >/dev/null 2>&1; then
    installed_version=$(keepassxc cli --version | grep -oP '[\d.]{3,}')
fi

if [ "$installed_version" = "$version" ]; then
    echo "Latest version ($version) already installed!"
    exit
fi

cd ~/downloads || exit 1
wget $url
chmod +x $file
mv -f $file /usr/local/bin/keepassxc
