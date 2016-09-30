#!/bin/sh
set -e

NVIM_PATH=${1:-neovim}
PREFIX=/opt/neovim

if [ ! -d $NVIM_PATH ]; then
	echo "[ERROR] Directory not found: $NVIM_PATH"
	echo "git clone https://github.com/neovim/neovim $NVIM_PATH"
	exit 1
elif [ ! -d $NVIM_PATH/.git ]; then
	echo "[ERROR] Not a git repository: $NVIM_PATH"
	echo "rm -rf $NVIM_PATH && git clone https://github.com/neovim/neovim $NVIM_PATH"
	exit 1
fi

cd $NVIM_PATH
if [ -z "$NO_GIT_PULL" ]; then
	git pull
fi

make CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX:PATH=$PREFIX" || exit 1

if [ ! -d $PREFIX ]; then
	sudo mkdir -f $PREFIX
fi
sudo chown $USER:$USER $PREFIX

make install

sudo chown -R root:staff $PREFIX

sudo ln -sf $PREFIX/bin/nvim /usr/local/bin/nvim

sudo update-alternatives --install /usr/bin/vim vim /usr/local/bin/nvim 60
sudo update-alternatives --set vim /usr/local/bin/nvim
