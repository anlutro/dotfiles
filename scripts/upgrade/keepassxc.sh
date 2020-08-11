#!/bin/sh
set -eu
# shellcheck source=_lib.sh
. "$(dirname "$(readlink -f "$0")")/_lib.sh"

# grep for digits removes alpha/beta/rc releases
url=$(gh_urls keepassxreboot/keepassxc | grep -P '\/[\d\.]+\/' | grep '\.AppImage$' | head -1)
version=$(basename $url | grep -oP '\d[\d.]{2,}\d')

if command -v keepassxc-cli >/dev/null 2>&1; then
    installed_version=$(keepassxc-cli --version | grep -oP '[\d.]{3,}')
elif command -v keepassxc >/dev/null 2>&1; then
    installed_version=$(keepassxc cli --version | grep -oP '[\d.]{3,}')
fi

if [ "$installed_version" = "$version" ]; then
	latest_already_installed
fi

filename=$(download $url)
install_bin $filename keepassxc
