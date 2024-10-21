#!/bin/sh
set -eu
# shellcheck source=_lib.sh
. "$(dirname "$(realpath "$0")")/_lib.sh"

repo=helm/helm
version="${1-}"
if [ -z "$version" ]; then
	# exclude alpha/beta/rc, and always get highest version number (as opposed to
	# most recent release by date)
	version=$(gh_tags $repo | grep -vF rc | grep -P '\d+(\.\d+)*$' | sort -V | tail -1)
fi
# strip "v" prefix
version=$(echo "$version" | grep -oP '\d+(\.\d+)*')

if helm version --template '{{.Version}}' | grep -qFx "$version"; then
	latest_already_installed
fi

# TODO: support arm64 somehow
platform=$(uname --kernel-name | tr '[:upper:]' '[:lower:]')-amd64
filename=$(download https://get.helm.sh/helm-v$version-$platform.tar.gz)
tmpdir=$(mktemp -d)
tar xf $filename -C $tmpdir
install_bin $tmpdir/$platform/helm
rm -rf $tmpdir
