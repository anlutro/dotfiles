#!/bin/sh -eu

version=$(curl -s https://api.github.com/repos/helm/helm/releases/latest | grep tag_name | cut -d '"' -f 4)

if helm version --template '{{.Version}}' | grep -qFx "$version"; then
    echo "Latest version ($version) already installed!"
    exit 1
fi

cd ~/downloads
wget https://get.helm.sh/helm-$version-linux-amd64.tar.gz
tar xf helm-$version-linux-amd64.tar.gz
cp linux-amd64/helm $HOME/.local/bin/
