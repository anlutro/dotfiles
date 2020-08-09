#!/bin/sh
set -eu

version=$(curl -s https://api.github.com/repos/fluxcd/flux/releases/latest | grep tag_name | cut -d '"' -f 4)

if fluxctl version | grep -qF "version: $version"; then
    echo "Latest version ($version) already installed!"
    exit 1
fi

cd ~/downloads || exit 1
wget -nv https://github.com/fluxcd/flux/releases/download/$version/fluxctl_linux_amd64
mv -f fluxctl_linux_amd64 $HOME/.local/bin/fluxctl
chmod 755 $HOME/.local/bin/fluxctl
