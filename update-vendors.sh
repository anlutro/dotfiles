#!/usr/bin/env sh

root=$(dirname "$(readlink -f "$0")")

update_fzf() {
    ./install --bin
}

update_git_crypt() {
    make && mv ./git-crypt ~/.local/bin
}

cd $root/vendor || exit 1
for dir in *; do
    name=$(basename "$dir")
    if [ ! -d "$dir" ]; then
        continue
    fi

    echo "Updating $name ..."
    cd $dir || exit 1
    git checkout .
    git pull

    func="update_$(echo "$name" | tr -s '-' '_')"
    if command -v "$func" >/dev/null 2>&1; then
        $func
    fi

    cd ..
    echo
done
