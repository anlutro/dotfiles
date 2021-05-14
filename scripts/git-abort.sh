#!/bin/sh
# shellcheck disable=SC2034

SUBDIRECTORY_OK=Yes
USAGE="[options]"
LONG_USAGE="\
Abort a rebase, am, cherry-pick or revert, depending on the
situation. Any options given will be passed on to the underlying
abort command."

. /usr/lib/git-core/git-sh-setup
. /usr/lib/git-core/git-sh-i18n
require_work_tree
cd_to_toplevel

if [ -e $GIT_DIR/CHERRY_PICK_HEAD ]; then
    exec git cherry-pick --abort "$@"
elif [ -e $GIT_DIR/REVERT_HEAD ]; then
    exec git revert --abort "$@"
elif [ -e $GIT_DIR/rebase-apply/applying ]; then
    exec git am --abort "$@"
elif [ -e $GIT_DIR/rebase-apply ] || [ -e $GIT_DIR/rebase-merge ]; then
    exec git rebase --abort "$@"
else
    echo "git-abort: unknown state"
    exit 1
fi
