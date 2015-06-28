#!/bin/sh

[ -d ~/.themes ] || mkdir ~/.themes

git_update() {
	name=$1
	repo=$2

	if [ -d $name ]; then
		cd $name
		echo "Checking theme $name for updates..."
		git remote update
		local_rev=$(git rev-list --max-count=1 master)
		remote_rev=$(git rev-list --max-count=1 origin/master)
		if [ "$local_rev" != "$remote_rev" ]; then
			git merge --ff-only origin/master
			rsync -av ./$name ~/.themes/$name
		fi
	else
		echo "Downloading theme $name..."
		git clone $repo $name
		cd $name
		rsync -av ./$name ~/.themes/$name
	fi

	cd ..
}

git_update Paper https://github.com/snwh/paper-gtk-theme
git_update Zukitwo https://github.com/lassekongo83/zuki-themes
