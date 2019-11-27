#!/bin/sh
set -eu

GIT_CRYPT_PATH=${1:-git-crypt}

if [ ! -d $GIT_CRYPT_PATH ]; then
    echo "[ERROR] Directory not found: $GIT_CRYPT_PATH"
    echo "git clone https://github.com/AGWA/git-crypt $GIT_CRYPT_PATH"
    exit 1
fi

cd $GIT_CRYPT_PATH
if [ -d $GIT_CRYPT_PATH/.git ]; then
    git pull
fi

make && mv git-crypt ~/bin
