#!/bin/sh

# chromium on debian has /etc/chromium.d but google-chrome doesn't, so this is
# the hack I have to work with

# sudo cp ./scripts/google-chrome.sh /opt/custom-google-chrome.sh
# sudo update-alternatives --install /usr/bin/google-chrome google-chrome /opt/custom-google-chrome.sh 10
# sudo update-alternatives --set google-chrome /opt/custom-google-chrome.sh

exec /opt/google/chrome/google-chrome \
	--high-dpi-support=1 \
	--force-device-scale-factor=1 \
	"$@"
