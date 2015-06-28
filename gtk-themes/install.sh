#!/bin/sh

[ -d ~/.themes ] || mkdir ~/.themes
cd $(dirname $(readlink -f $0))

git_update() {
	repo=$1
	shift
	# grab everything after the last /
	dir=$(echo $repo |sed 's/.*\///')

	# clone the repo if it doesn't exist
	if [ ! -d $dir ]; then
		git clone $repo $dir
		cloned=true
		update=true
	fi

	cd $dir

	# unless the repository was cloned, do a remote update
	if [ "$clone" != true ]; then
		git remote update
		local_rev=$(git rev-list --max-count=1 master)
		remote_rev=$(git rev-list --max-count=1 origin/master)
		if [ "$local_rev" != "$remote_rev" ]; then
			git merge --ff-only origin/master
			update=true
		fi
	fi

	# each repository can contain multiple themes. loop through all the
	# remaining variables and check if any need to be updated
	name=$1
	while [ "$name" != "" ]; do
		if [ ! -d ~/.themes/$name ] || [ "$update" = true ]; then
			rsync -av ./$name ~/.themes/$name
		fi
		shift
		name=$1
	done

	cd ..
}

git_update https://github.com/snwh/paper-gtk-theme Paper
git_update https://github.com/lassekongo83/zuki-themes Zukiwi Zukitwo Zukitre
