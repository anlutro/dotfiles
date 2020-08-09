#!/bin/sh
set -eu

version=$(curl -s https://api.github.com/repos/gruntwork-io/terragrunt/releases/latest | grep tag_name | cut -d '"' -f 4)

if terragrunt --version | grep -qF "version $version"; then
    echo "Latest version ($version) already installed!"
    exit 1
fi

cd ~/downloads || exit 1
wget -nv https://github.com/gruntwork-io/terragrunt/releases/download/$version/terragrunt_linux_amd64
mv -f terragrunt_linux_amd64 $HOME/.local/bin/terragrunt
chmod 755 $HOME/.local/bin/terragrunt
