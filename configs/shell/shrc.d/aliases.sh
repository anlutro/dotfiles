#!/bin/sh

# enable colors for grep
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias zgrep='zgrep --color=auto'

# I always have to google this one
alias grep-non-unicode='grep -P -n "[^\x00-\x7F]"'

# ag doesn't have config files
if which ag >/dev/null 2>&1; then
    alias ag="ag --color-path='0;37' --color-line-number='0;33' --color-match='1;34'"
fi

# some ls aliases
alias ls='ls --group-directories-first --color=auto --classify --human-readable'
if which exa >/dev/null 2>&1; then
    alias exa='exa --group-directories-first'
    alias l='exa --long'
    alias la='exa --long --all'
    alias lt='exa --long --sort=new'
else
    alias l='ls -l'
    alias la='l -A'
    alias lt='l -tr'
fi

# file and dir stuff
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias rm='rm -I --preserve-root'
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'

# i3 shortcuts
alias i3exec='i3-msg exec'
alias i3rename='i3-msg rename workspace to'
alias i3mv='i3-msg move workspace to output'

# venv.sh
alias av='venv activate'
alias avenv='venv activate'
alias mkvenv='venv create'
alias rmvenv='venv destroy'

# misc
alias cal='ncal -Mb3'
alias dc='docker-compose'
alias gdiff='git diff --no-index'
alias jn='jupyter-notebook'
alias k='kubectl'
alias most-common='sort | uniq -c | sort -nr | head'
alias pwgen-strong='pwgen -Bs'
alias pwgen-weak='pwgen -ABn'
alias tf='terraform'
alias tg='terragrunt'
alias tree='tree --dirsfirst'
alias n='notes --new'
alias nl='notes --list'
alias ns='notes --search'
alias nrm='notes --remove'
alias v='vagrant'