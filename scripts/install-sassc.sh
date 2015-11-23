#!/bin/sh

cd ${1-libsass} || exit 1
git pull
cd sassc || exit 1
git pull
cd ..
make sassc || make sassc || exit 1
cp sassc/bin/sassc ~/bin/sassc
