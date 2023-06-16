#!/bin/sh

# make a directory and cd into it
function md {
    mkdir -p "$@" && cd "$_" || return 1;
}

# by default, most WMs opening a new terminal will make it start in ~ instead of
# the current terminal's PWD. this alias lets you open a new terminal in the PWD
function t {
    history -a
    if command -v i3-msg >/dev/null 2>&1; then
        # opening through i3 exec prevents weird/inconsistent ps trees
        i3-msg exec "$HOME/code/dotfiles/scripts/term.sh -w '$PWD' $*" >/dev/null
    else
        # forking in subshell suppresses all output and keeps terminal open
        # even if parent terminal is closed
        ( $HOME/code/dotfiles/scripts/term.sh "$@" & )
    fi
}

# set a terminal's title
function termname {
    echo -ne "\033]0;$1\007"
}

# improved ps | grep alias
function psgrep {
    ps auxf | grep "$@" | grep -v grep;
}

# livestreamer/streamlink
function sl {
    args=""
    stream=""
    quality=""
    for arg in "$@"; do
        case $arg in
            -* )
                args="$args $arg"
                ;;
            * )
                if [ -z "$stream" ]; then
                    stream="$arg"
                elif [ -z "$quality" ]; then
                    quality="$arg"
                else
                    args="$args $arg"
                fi
                ;;
        esac
        shift
    done
    if [ -z "$quality" ]; then
        quality=best
    fi
    streamlink $stream $quality $args
}

# php in docker
function dphp {
    local tty_arg
    tty -s && tty_arg=--tty
    docker run --rm --interactive $tty_arg \
        --volume $PWD:$PWD --workdir $PWD \
        --user "$(id -u):$(id -g)" \
        --network host \
        php:${php_version-8}-cli-alpine php "$@"
}

# composer in docker
function dcomposer {
    mkdir -p $HOME/.config/composer
    local tty_arg
    tty -s && tty_arg=--tty
    docker run --rm --interactive $tty_arg \
        --volume $PWD:$PWD --workdir $PWD \
        --volume $HOME/.config/composer:/tmp \
        --user "$(id -u):$(id -g)" \
        --volume $SSH_AUTH_SOCK:/ssh-auth.sock \
        --env SSH_AUTH_SOCK=/ssh-auth.sock \
        composer:${composer_version-2} "$@"
}

# find and remove pycache files
function clear-pycache {
    find . -type f -name '*.pyc' -print0 | xargs --no-run-if-empty -0 rm
    find . -type d -name '*.egg-info' -print0 | xargs --no-run-if-empty -0 rm -rf
    find . -type d -name '__pycache__' -print0 | xargs --no-run-if-empty -0 rm -rf
}

# clone a github repository
function gh-clone {
    git clone https://github.com/"$*"
}

# fetch a github pull request
function gh-fetch-pr {
    local remote
    remote=$(git remote -v | grep '(fetch)' | grep 'github.com' | cut -f 1)
    if [ -n "$remote" ]; then
        git fetch $remote "pull/$1/head:pr-$1"
    else
        echo >&2 "No github remote found!"
        return 1
    fi
}

function gh-checkout-pr {
    gh-fetch-pr "$1" && git checkout "pr-$1"
}

function hex2oct {
    echo "obase=8; ibase=16; $*" | bc
}
function hex2dec {
    echo "obase=10; ibase=16; $*" | bc
}
function oct2hex {
    echo "obase=16; ibase=8; $*" | bc
}
function oct2dec {
    echo "obase=10; ibase=8; $*" | bc
}

# list network stuff
function lsn {
    local args="-n -P"
    local proto=""
    local state_arg=""
    for arg in "$@"; do
        case $arg in
            -u )
                proto="udp"
                ;;
            -t )
                proto="tcp"
                ;;
            -l )
                state_arg="-stcp:listen"
                ;;
            * )
                args="$args $arg"
                ;;
        esac
        shift
    done
    args="$args -i${proto} $state_arg"
    sudo lsof $args
}

# print field
function f {
    awk "{ print \$$1 }"
}

function whatsmyip {
    dig -4 TXT +short o-o.myaddr.l.google.com @ns1.google.com
}

# check ssl dates
function ssl-dates {
    cmd="echo -n Q | openssl s_client -connect \"${1}:${2-443}\" -servername \"$1\" 2>/dev/null | openssl x509 -noout -subject -ext subjectAltName -dates"
    echo "$cmd"
    eval "$cmd"
}
