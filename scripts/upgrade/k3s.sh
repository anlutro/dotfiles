#!/bin/sh
set -eu

version=$(curl -s https://api.github.com/repos/rancher/k3s/releases/latest | grep tag_name | cut -d '"' -f 4)

if k3s --version | grep -qF "$version"; then
    echo "Latest version ($version) already installed!"
    exit 1
fi

cd ~/downloads
wget -nv https://github.com/rancher/k3s/releases/download/$version/k3s
mv -f k3s $HOME/.local/bin/
chmod +x $HOME/.local/bin/k3s
