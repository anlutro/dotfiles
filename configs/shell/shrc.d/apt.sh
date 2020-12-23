if command -v apt-get >/dev/null 2>&1; then
    function apt-everything {
        for cmd in update dist-upgrade autoremove clean; do
            sudo apt $cmd
        done
        purge_pkgs=$(dpkg -l | grep '^rc' | awk '{ print $2 }')
        sudo apt purge $purge_pkgs
        if command -v apt-file >/dev/null 2>&1; then
            sudo apt-file update
        fi
    }

    # apt-key add is meh
    function apt-add-key {
        url="$1"
        if [ -n "$2" ]; then
            file="$2"
        else
            file="$(basename $url)"
        fi
        file="${file%.*}.gpg"
        curl -sSL "$1" | gpg --dearmor > $file
        sudo chown root:root $file
        sudo mv $file /etc/apt/trusted.gpg.d/
    }
fi
