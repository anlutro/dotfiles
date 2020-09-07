#!/bin/sh

txt="Neque porro quisquam est qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit..."

notify-send --urgency=low "Low urgency notification title" "$txt"
notify-send --urgency=normal "Normal notification title" "$txt"
notify-send --urgency=critical "Critical notification!" "$txt"
