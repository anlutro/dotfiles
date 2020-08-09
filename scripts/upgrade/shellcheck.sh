#!/bin/sh
set -eu

version=$(curl -s https://api.github.com/repos/koalaman/shellcheck/releases/latest | grep tag_name | cut -d '"' -f 4)
version_num=$(echo "$version" | sed s/^v//)

if shellcheck --version | grep -qF "version: $version_num"; then
    echo "Latest version ($version) already installed!"
    exit 1
fi

cd ~/downloads
wget -nv https://github.com/koalaman/shellcheck/releases/download/$version/shellcheck-$version.linux.x86_64.tar.xz
tar xf shellcheck-$version.linux.x86_64.tar.xz
mv shellcheck-$version/shellcheck $HOME/.local/bin
rm -rf shellcheck-$version shellcheck-$version.linux.x86_64.tar.xz
