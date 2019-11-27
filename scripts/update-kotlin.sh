#!/bin/sh
set -eux

URL=$(
    curl -s https://api.github.com/repos/JetBrains/kotlin/releases | \
    grep -F browser_download_url | grep -F linux-x64 | head -1 | cut -d\" -f4
)
FILE=$(basename $URL)
VERSION=$(echo $FILE | grep -oP '\d+(\.\d+)+')

if kotlin -version | grep -qF "$VERSION"; then
    echo "Latest version ($VERSION) already installed!"
    exit 1
fi

if [ -w /usr/local ]; then
    PRE_PREFIX="/usr/local"
else
    PRE_PREFIX="$HOME/.local"
fi
PREFIX="$PRE_PREFIX/share/kotlin-$VERSION"

cd ~/downloads || exit 1
# wget $URL
unzip $FILE
rsync -r ./kotlinc/ $PREFIX
rm -rf ./kotlinc

for bin in kotlin kotlinc; do
    ln -sf $PREFIX/bin/$bin $PRE_PREFIX/bin
done
