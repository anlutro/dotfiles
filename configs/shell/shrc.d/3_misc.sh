#!/bin/sh

# make a directory and cd into it
function md {
	mkdir -p "$@" && cd "$_" || return 1;
}

function apt-everything {
	for cmd in update dist-upgrade autoremove clean; do
		sudo apt $cmd
	done
	purge_pkgs=$(dpkg -l | grep '^rc' | awk '{ print $2 }')
	sudo apt purge $purge_pkgs
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

# by default, most WMs opening a new terminal will make it start in ~ instead of
# the current terminal's PWD. this alias lets you open a new terminal in the PWD
function t {
	local args="";
	if [ "$*" != "" ]; then
		args="-e $*"
	fi

	args="-cd $PWD $args"

	if command -v i3-msg >/dev/null 2>&1; then
		# opening through i3 exec prevents weird/inconsistent ps trees
		i3-msg "exec x-terminal-emulator $args" >/dev/null 2>&1
	else
		# fork in a subshell to make the commands indepentent,
		# and to suppress all output.
		( x-terminal-emulator $args & )
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

# set the keyboard map
function kb {
	setxkbmap -v -option compose:ralt -option caps:super $1 \
		&& xset r rate 175 35
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
		--volume $PWD:/usr/src/myapp \
		--user "$(id -u):$(id -g)" \
		--workdir /usr/src/myapp \
		--network host \
		php:7-cli-alpine php "$@"
}

# composer in docker
function dcomposer {
	local tty_arg
	tty -s && tty_arg=--tty
	docker run --rm --interactive $tty_arg \
		--volume $PWD:/app \
		--volume $HOME/.config/composer:/tmp \
		--user "$(id -u):$(id -g)" \
		--volume $SSH_AUTH_SOCK:/ssh-auth.sock \
		--env SSH_AUTH_SOCK=/ssh-auth.sock \
		composer "$@"
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
		echo "No github remote found!"
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

function f {
	awk "{ print \$$1 }"
}
