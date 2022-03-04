#!/bin/sh
set -eu
# shellcheck source=_lib.sh
. "$(dirname "$(realpath "$0")")/_lib.sh"

version=$(gh_latest_tag bitnami-labs/sealed-secrets/releases/latest)

if kubeseal --version | grep -qF "version: $version"; then
	latest_already_installed
fi

filename=$(download https://github.com/bitnami-labs/sealed-secrets/releases/download/$version/kubeseal-linux-amd64)
install_bin $filename kubeseal
