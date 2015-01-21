# enable colors for grep
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# some ls aliases
alias ls='ls --group-directories-first --color=never -F'
alias l='ls -lh'
alias lc='l --color=auto'
alias la='l -A'
alias lt='l -tr'

# file and dir stuff
function md { mkdir -p "$@" && cd $_; }
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias rm='rm -I --preserve-root'
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'

function psgrep() {
	ps auxf | grep -v grep | grep "$@";
}

# server stuff
alias a2r='sudo service apache2 reload'
alias a2rs='sudo service apache2 restart'
alias a2cs='\ls /etc/apache2/sites-enabled/'
alias a2em='sudo a2enmod'
alias a2dm='sudo a2dismod'
alias a2cfg='cd /etc/apache2 && ls'
alias a2log='cd /var/log/apache2 && ls -l'

function a2es {
	if [[ $(whoami) != "vagrant" ]]; then
		echo "ABORTED: Not running in vagrant!"; return 1;
	fi

	if [ ! -f /etc/apache2/sites-available/$1 ]; then
		echo "ABORTED: No such site available!"; return 2;
	fi

	if [ "$(ls -A /etc/apache2/sites-enabled)" ]; then
		sudo rm /etc/apache2/sites-enabled/*
	fi
	sudo ln -s /etc/apache2/sites-available/$1 /etc/apache2/sites-enabled/$1 && sudo service apache2 reload
}

# php stuff
function art {
	if [ -f ./bin/artisan ]; then
		php ./bin/artisan $@
	elif [ -f ./artisan ]; then
		php ./artisan $@
	else
		echo "No artisan file found!"; return 1;
	fi
}

# python
alias avenv='source ./virtualenv/bin/activate'
function pyhelp {
	python -c 'help('"$@"')'
}
function py3help {
	python3 -c 'help('"$@"')'
}

# misc
alias crlffix='for file in `find . -type f`; do dos2unix $file; done'
alias ss='sudo service'
alias s='livestreamer'

# generate a password
function genpw {
	if [ -n "$1" ]; then
		len=$1
	else
		len=8
	fi

	chars="abcdefghjkmnpqrtuvwxyz2346789"
	if [ "$2" == "strong" ]; then
		chars=$chars"ABCDEFGHJKMNPQRTUVWXYZ!@#$%&.:,;-"
	fi

	< /dev/urandom tr -dc $chars | head -c${1:-$len}
	echo # newline
}

# clear a file, then tail it
function cltail {
	cat /dev/null > "$1" && tail -f "$@"
}

# keyboard layout
function kb {
	setxkbmap -v $1 && xset r 66
}
