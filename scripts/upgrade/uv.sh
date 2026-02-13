#!/bin/sh
set -eu
# shellcheck source=_lib.sh
. "$(dirname "$(realpath "$0")")/_lib.sh"

url=$(gh_urls astral-sh/uv | grep x86_64-unknown-linux-gnu | head -1)
version=$(echo $url | sed -r 's|.*/download/([0-9.-]+)/.*|\1|')

if uv --version 2>&1 | grep -q " $version$"; then
	latest_already_installed
fi

filename=$(download $url)
tar xvf $filename
install_bin uv-x86_64-unknown-linux-gnu/uv
install_bin uv-x86_64-unknown-linux-gnu/uvx
