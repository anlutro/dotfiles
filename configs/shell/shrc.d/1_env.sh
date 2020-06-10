#!/bin/sh

# don't put duplicate lines or lines starting with space in the history.
export HISTCONTROL=ignoreboth

# history size in memory
export HISTSIZE=5000
# history size in history file
export SAVEHIST=50000
export HISTFILESIZE=50000
export HISTFILE=~/.history

# always limit man to 80 characters wide
export MANWIDTH=80

# need this for signing commits with git, for some reason
GPG_TTY=$(tty)
export GPG_TTY

# make less more friendly for non-text input files, see lesspipe(1)
test -x /usr/bin/lesspipe && eval "$(SHELL=/bin/sh lesspipe)"

# ls --color config with dircolors
export LS_COLORS='fi=0:di=1;34:ow=1;34:ln=33:ex=1;32:mi=0;31'

# self-explanatory
export EDITOR=vim

# less options
export LESS='M x4'
export GIT_PAGER='less -FRX -x5,9'
export SYSTEMD_LESS='KMR +G'
# export SYSTEMD_LESS='FKMRX +G'

# go
export GOPATH=~/.gopath
export GO111MODULE=on

# docker
export DOCKER_BUILDKIT=1
export DOCKER_CLI_EXPERIMENTAL=enabled
export DOCKER_HIDE_LEGACY_COMMANDS=1

# avoid weird scaling in qt5
export QT_AUTO_SCREEN_SCALE_FACTOR=0

# ansible
export ANSIBLE_VAULT_PASSWORD_FILE=./.ansible-vault-password
