#!/bin/sh

sp=$(find . -maxdepth 1 -name '*.sublime-project')

if [ -z "$sp" ]; then
	sp="."
fi

subl -n "$sp"
