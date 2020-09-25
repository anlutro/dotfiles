#!/bin/sh

script=$(find ~/.screenlayout -type f -printf '%f\n' | rofi -dmenu -p 'select screen layout')
~/.screenlayout/$script
