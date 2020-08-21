#!/bin/sh

if [ -w /usr/local ]; then
    BIN_DIR=/usr/local/bin
    SHARE_DIR=/usr/local/share
else
    BIN_DIR="$HOME/.local/bin"
    SHARE_DIR=$HOME/.local/share
fi

confirm() {
    echo -n "$* [Y/n] "
    read REPLY
    if [ -z "$REPLY" ] || [ "$REPLY" != "${REPLY#[Yy]}" ]; then
        return 0
    fi
    return 1
}

install_bin() {
    src="$1"
    dest="$BIN_DIR/${2-$(basename $src)}"
    mv -f "$src" "$dest"
    chmod +x "$dest"
}

get_prefix() {
    echo "$SHARE_DIR/$1"
}

fail() {
    echo "$*" >&2
    exit 1
}

latest_already_installed() {
    script="$(basename "$(readlink -f "$0")")"
    name="${script%%.*}"
    echo "Latest version of $name ($version) is already installed!" >&2
    exit 0
}

download() {
    url="$1"
    filename="${2-$(basename $url)}"
    cd ~/downloads || exit 1
    wget "$1" -O "$filename"
    if [ -z "${2-}" ]; then
        readlink -f "$filename"
    fi
}

download_gh_release() {
    repo="$1"
    version="$2"
    filename="$3"
    download "https://github.com/$repo/releases/download/$version/$filename" "$filename"
}

gh_urls() {
    repo="$1"
    curl -s "https://api.github.com/repos/$repo/releases" \
        | grep browser_download_url | cut -d\" -f4
}

gh_latest_urls() {
    repo="$1"
    curl -s "https://api.github.com/repos/$repo/releases/latest" \
        | grep browser_download_url | cut -d\" -f4
}

gh_tags() {
    repo="$1"
    curl -s "https://api.github.com/repos/$repo/tags?per_page=100" \
        | grep name | cut -d '"' -f 4
}

gh_releases() {
    repo="$1"
    curl -s "https://api.github.com/repos/$repo/releases?per_page=100" \
        | grep tag_name | cut -d '"' -f 4
}

gh_latest_tag() {
    repo="$1"
    curl -s "https://api.github.com/repos/$repo/releases/latest" \
        | grep tag_name | cut -d '"' -f 4
}

dpkg_l=""
check_apt_pkg() {
    pattern="$1"
    if [ -z "$dpkg_l" ]; then
        dpkg_l="$(dpkg -l)"
    fi
    if ! echo "$dpkg_l" | grep -q "$pattern"; then
        echo "warning: package matching pattern '$pattern' not found!"
        exit 1
    fi
}
