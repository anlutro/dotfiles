#!/bin/sh

cd ${1-libsass}
git pull
cd sassc
git pull
cd ..
make sassc || make sassc
cp sassc/bin/sassc ~/bin/sassc
