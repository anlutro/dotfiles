#!/bin/sh

# chromium on debian has /etc/chromium.d but google-chrome doesn't, so this is
# the hack I have to work with.

# copy this script to /usr/local/bin/chrome (or chromium)

find_bin() {
    try_bins="
    /opt/google/chrome/google-chrome
    /usr/bin/google-chrome
    /usr/bin/chromium
    "
    for bin in $try_bins; do
        if [ -e $bin ]; then
            echo $bin
            return
        fi
    done
    echo "could not find a chrome/chromium binary!" >&2
    exit 1
}

bin=$(find_bin)

exec $bin \
    --high-dpi-support=1 \
    --force-device-scale-factor=1 \
    "$@"
