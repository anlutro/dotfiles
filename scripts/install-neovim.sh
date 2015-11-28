#!/bin/sh

cd ${1-neovim} || exit 1
git pull
make
sudo rm /usr/local/share/nvim/runtime/doc/*.awk
sudo rm /usr/local/share/nvim/runtime/*.vim
sudo rm /usr/local/share/nvim/runtime/syntax/*.vim
sudo rm /usr/local/share/nvim/runtime/ftplugin/*.vim
sudo rm /usr/local/share/nvim/runtime/autoload/*.vim
sudo rm /usr/local/share/nvim/runtime/tutor/*.tutor
sudo checkinstall
sudo update-alternatives --install /usr/bin/vim vim /usr/local/bin/nvim 60
sudo update-alternatives --set vim /usr/local/bin/nvim
