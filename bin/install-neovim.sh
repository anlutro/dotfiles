#!/bin/sh

cd ${1-neovim} || exit 1
git pull
make
sudo rm /usr/local/share/nvim/runtime/doc/*.awk
sudo rm /usr/local/share/nvim/runtime/*.vim
sudo rm /usr/local/share/nvim/runtime/syntax/*.vim
sudo rm /usr/local/share/nvim/runtime/ftplugin/*.vim
sudo checkinstall
