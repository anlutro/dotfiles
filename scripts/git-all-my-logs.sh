#!/bin/bash
# shellcheck disable=SC2034

SUBDIRECTORY_OK=Yes
NONGIT_OK=Yes
USAGE="[options]"
LONG_USAGE="\
Collect git commits made by you in all subdirectories in PWD that
are git repositories. Extra args are passed to git log. Example:

  cd ~/code
  git all-my-logs --since=yesterday
"

. ${GIT_EXEC_PATH}/git-sh-setup
. ${GIT_EXEC_PATH}/git-sh-i18n
# require_work_tree
# cd_to_toplevel

root=$(pwd)
author=$(git config user.name)

for d in $root/*; do
    if [ ! -d "$d" ] || [ ! -d "$d/.git" ]; then
        continue
    fi
    repo="$(basename "$d")"
    git --no-pager -C "$d" log --all --author="$author" \
        --date=format:"%F %H:%M (%a wk%V)" \
        --pretty=tformat:"%C(green)%ad%C(reset) %C(yellow)[$repo]%C(reset) %s" "$@"
done | sort
