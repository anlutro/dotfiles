# enable colors for grep
if [ -x /usr/bin/dircolors ]; then
	test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
	alias grep='grep --color=auto'
	alias fgrep='fgrep --color=auto'
	alias egrep='egrep --color=auto'
fi

# some ls aliases
alias ls='ls --color=never -F'
alias lc='ls --color=auto'
alias la='ls -A'
alias l='ls -lh'
alias ll='ls -lhA'

alias c='clear'

function md { mkdir -p "$@" && cd $_; }

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

alias rm='rm -I --preserve-root'

alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'

alias a2r='sudo service apache2 reload'
alias a2rs='sudo service apache2 restart'
#alias a2es='sudo a2ensite'
#alias a2ds='sudo a2dissite'
alias a2cs='\ls /etc/apache2/sites-enabled/'
alias a2em='sudo a2enmod'
alias a2dm='sudo a2dismod'
alias a2cfg='cd /etc/apache2 && ls'
alias a2log='cd /var/log/apache2 && ls -l'

function a2es {
	if [ "$(ls -A /etc/apache2/sites-enabled)" ]; then
		sudo rm /etc/apache2/sites-enabled/*
	fi
	sudo ln -s /etc/apache2/sites-available/$1 /etc/apache2/sites-enabled/$1 && sudo service apache2 reload
}

function s {
	if [ "$(which apache2)" ]; then service apache2 status; fi;
	if [ "$(which nginx)" ]; then service nginx status; fi;
	if [ "$(which mysql)" ]; then service mysql status; fi;
	# if [ "$(which redis-server)" ]; then redis-cli info; fi;
	# if [ "$(which memcached)" ]; then service memcached status; fi;
}

alias a='php artisan'
alias crlffix='for file in `find . -type f`; do dos2unix $file $file; done'
alias genpw='< /dev/urandom tr -dc A-Za-z0-9 | head -c${1:-16};echo;'

# python
alias avenv='source ./virtualenv/bin/activate'

function kb {
	setxkbmap -v $1 && xset r 66
}
