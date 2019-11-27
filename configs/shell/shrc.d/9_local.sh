#!/bin/sh

# local overrides
if [ -f "$HOME/.shrc" ]; then
    . "$HOME/.shrc"
fi
if [ -f "$HOME/.shrc.local" ]; then
    . "$HOME/.shrc.local"
fi
