#!/bin/sh

confirm() {
    echo -n "$* [Y/n] "
    read REPLY
    if [ -z "$REPLY" ] || [ "$REPLY" != "${REPLY#[Yy]}" ]; then
        return 0
    fi
    return 1
}

# attempt to get rid of mouse + scroll wheel acceleration
defaults write -g com.apple.mouse.scaling -int -1
defaults write -g com.apple.scrollwheel.scaling -int -1

# un-invert scrolling
defaults write -g com.apple.swipescrolldirection -int 0

# I don't like homebrew but there are no good alternatives
if ! command -v brew >/dev/null 2>&1 && confirm "Install Homebrew?"; then
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

	# gnu utils to replace horribly out of date bsd grep/awk etc.
	brew install coreutils findutils gawk grep gnu-tar gnu-sed gnu-getopt
fi
