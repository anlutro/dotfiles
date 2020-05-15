# dotfiles

This git repository contains most of my Linux configuration files, as well as a bunch of utility scripts. I don't bother using Ansible or anything like that, almost everything is shell scripts.

When I install a new laptop, I run `scripts/install-debian.sh` as `root` to make some system-level configuration and install most of the packages I use day-to-day, but I still install a lot of packages manually. I don't have an exhaustive list of all packages I use.

As my own user, I run `install.sh` to set up symlinks from files in this repository to `~/.config` and whatever other paths are used for application configuration, so that when I `git pull`, application configuration is automatically updated. I don't want to have to run an extra compilation step.

I also use some third-party git repos, which can be updated with `update-vendor.sh`.
