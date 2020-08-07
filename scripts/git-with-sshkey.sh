#!/bin/sh
set -eu

if [ -f $1 ]; then
    GIT_IDENTITY=$1 && shift
elif [ -z $GIT_IDENTITY ]; then
    echo 'Must provide SSH key file as first argument or as GIT_IDENTITY environment variable.'
    exit 1
fi

SSHWRAPPER=$(mktemp --suffix=ssh-git-id-wrapper)
echo "#!/bin/sh" > $SSHWRAPPER
echo "exec ssh -i $GIT_IDENTITY -o IdentitiesOnly=yes -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no \$*" >> $SSHWRAPPER
chmod 755 $SSHWRAPPER
GIT_SSH=$SSHWRAPPER git "$@"
rm $SSHWRAPPER
