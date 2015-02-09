if [ $(whoami) = "vagrant" ]; then
    color="33" # yellow
elif [ -n "$SSH_CLIENT" ]; then
    color="31" # red
else
    color="32" # green
fi

PS1='${debian_chroot:+($debian_chroot)}\[\033[01;'$color'm\]\u@\h\[\033[00m\]:\[\033[00;37m\]\w\[\033[00m\]'

if command -v __git_ps1 >/dev/null 2>&1; then
    PS1=$PS1'$(__git_ps1 " (%s)")'
fi

if [ $(whoami) = 'root' ]; then
    PS1=$PS1'\n# '
else
    PS1=$PS1'\n$ '
fi
