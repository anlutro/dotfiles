# note taking
function n {
	if [[ ! $1 ]]; then
		echo "Missing argument - usage: n <name>"
		return
	fi
	count=$(nls $1 | wc -l)
	if [[ $count > 1 ]]; then
		nls $1
		return
	elif [[ $count == 0 ]]; then
		nano $1.md
	else
		nano $(nls $1)
	fi
}
function nls {
	ls -1 ~/Dropbox/notes/*.md | grep $@
}

# enable colors for grep
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# ag doesn't have config files
alias ag="ag --color-path='0;37' --color-line-number='0;33' --color-match='1;34'"

# some ls aliases
alias ls='ls --group-directories-first --color=never -F'
alias l='ls -lh'
alias lc='l --color=auto'
alias la='l -A'
alias lt='l -tr'

# file and dir stuff
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias rm='rm -I --preserve-root'
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'

function md {
	mkdir -p "$@" && cd $_;
}

# i3
alias i3-rename='i3-msg rename workspace to'

# server stuff
alias a2r='sudo service apache2 reload'
alias a2rs='sudo service apache2 restart'
alias a2cs='\ls /etc/apache2/sites-enabled/'
alias a2em='sudo a2enmod'
alias a2dm='sudo a2dismod'
alias a2cfg='cd /etc/apache2 && ls'
alias a2log='cd /var/log/apache2 && ls -l'

# php
function ccp {
	composer create-project "$1" -s dev --prefer-dist "${*:2}";
}

# python
alias avenv='source ./.virtualenv/bin/activate'
function pyhelp {
	python -c 'help('"$@"')'
}
function py3help {
	python3 -c 'help('"$@"')'
}

# misc
alias crlffix='for file in `find . -type f`; do dos2unix $file; done'
alias ss='sudo service'
alias i3lock='i3lock -c 000000'
alias tree='tree --dirsfirst'

# livestreamer
function s {
	livestreamer $1 ${2-high,720p,best}
}

# clear a file, then tail it
function cltail {
	cat /dev/null > "$1" && tail -f "$@"
}

# keyboard layout
function kb {
	setxkbmap -v $1 && xset r 66
}

# improved ps | grep alias
function psgrep() {
	ps auxf | grep -v grep | grep "$@";
}
