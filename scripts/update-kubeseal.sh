#!/bin/sh

version=$(curl -s https://api.github.com/repos/bitnami-labs/sealed-secrets/releases/latest | grep tag_name | cut -d '"' -f 4)

if kubeseal --version | grep -qF "version: $version"; then
    echo "Latest version ($version) already installed!"
    exit 1
fi

cd ~/downloads || exit 1
wget https://github.com/bitnami-labs/sealed-secrets/releases/download/$version/kubeseal-linux-amd64
cp kubeseal-linux-amd64 $HOME/.local/bin/kubeseal
chmod 755 $HOME/.local/bin/kubeseal
