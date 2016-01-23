#!/bin/sh

NVIM_PATH=${1:-neovim}

if [ ! -d $NVIM_PATH ]; then
	echo "[ERROR] Directory not found: $NVIM_PATH"
	echo "git clone https://github.com/neovim/neovim $NVIM_PATH"
	exit 1
elif [ ! -d $NVIM_PATH/.git ]; then
	echo "[ERROR] Not a git repository: $NVIM_PATH"
	echo "rm -rf $NVIM_PATH && git clone https://github.com/neovim/neovim $NVIM_PATH"
	exit 1
fi

cd $NVIM_PATH || exit 1
git pull
make
sudo rm /usr/local/share/nvim/runtime/doc/*.awk
sudo rm /usr/local/share/nvim/runtime/*.vim
sudo rm /usr/local/share/nvim/runtime/syntax/*.vim
sudo rm /usr/local/share/nvim/runtime/ftplugin/*.vim
sudo rm /usr/local/share/nvim/runtime/autoload/*.vim
sudo rm /usr/local/share/nvim/runtime/tutor/*.tutor
sudo rm /usr/local/share/nvim/runtime/indent/*.vim
sudo checkinstall -y --pkgname neovim make install
sudo update-alternatives --install /usr/bin/vim vim /usr/local/bin/nvim 60
sudo update-alternatives --set vim /usr/local/bin/nvim
