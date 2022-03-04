#!/bin/sh
set -eu
# shellcheck source=_lib.sh
. "$(dirname "$(realpath "$0")")/_lib.sh"

version=$(
	curl -sSL https://releases.hashicorp.com/terraform/ \
	| grep -vP -- '-(alpha|beta|rc)' \
	| grep -oP 'terraform_[\d.]+' | sed 's/^terraform_//' \
	| sort -V | uniq | grep "${1-.*}" | tail -1
)
url="https://releases.hashicorp.com/terraform/${version}/terraform_${version}_linux_amd64.zip"

if terraform --version | grep -qxF "Terraform v$version"; then
	latest_already_installed
fi

filename=$(download $url)
unzip $filename
tf_versioned_bin=terraform$(echo "$version" | cut -d. -f-2)
install_bin ./terraform $tf_versioned_bin
ln -sf $tf_versioned_bin $BIN_DIR/terraform
rm -f $filename
