#!/bin/sh
set -eu
# shellcheck source=_lib.sh
. "$(dirname "$(realpath "$0")")/_lib.sh"

repo=helmfile/helmfile
version=$(gh_latest_tag $repo)
version_num=$(echo "$version" | sed 's/^v//')

if helmfile --version | grep -qF "version $version_num"; then
    latest_already_installed
fi

filename=$(download https://github.com/$repo/releases/download/$version/helmfile_${version_num}_linux_amd64.tar.gz)
tar xf $filename helmfile
install_bin helmfile
