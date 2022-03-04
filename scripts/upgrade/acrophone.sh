#!/bin/sh
set -eu
# shellcheck source=_lib.sh
. "$(dirname "$(realpath "$0")")/_lib.sh"

url=$(gh_urls bcicen/acrophone | grep linux-amd64 | head -1)
version=$(echo $url | sed -r 's|.*/download/v([0-9.-]+)/.*|\1|')

if acrophone --version 2>&1 | grep -qF "version $version,"; then
	latest_already_installed
fi

filename=$(download $url)
install_bin $filename acrophone
