#!/bin/sh
set -eu

# shellcheck source=_lib.sh
. "$(dirname "$(realpath "$0")")/_lib.sh"

url=$(gh_urls docker/compose | grep -i linux-x86_64 | grep -v -- '-rc' | head -1)
version=$(echo $url | sed -r 's|.*/download/([0-9.-]+)/.*|\1|')

if cmd_exists docker-compose && docker-compose --version | grep -qF "version $version,"; then
	latest_already_installed
fi

filename=$(download $url)
install_bin $filename docker-compose
