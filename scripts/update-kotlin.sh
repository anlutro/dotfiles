#!/bin/sh

url=$(curl -s https://api.github.com/repos/JetBrains/kotlin/releases | grep browser_download_url | grep \.zip | head -1 | cut -d\" -f4)
file=$(basename $url)
version=$(echo $file | sed -r 's/.*kotlin-compiler-([0-9.-]+)\.zip/\1/')

if kotlin -version | grep $version; then
	echo "Latest version ($version) already installed!"
	exit 1
fi

cd ~/Downloads
wget $url
unzip $file
sudo rm -rf /opt/kotlinc
sudo mv ./kotlinc /opt/
rm $file

for bin in kotlin kotlinc; do
	sudo ln -sf /opt/kotlinc/bin/$bin /usr/local/bin/
done
