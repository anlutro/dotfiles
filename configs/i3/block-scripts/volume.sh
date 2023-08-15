#!/bin/sh

if command -v wpctl >/dev/null 2>&1; then
    volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2}')
    pct=$(echo "$volume * 100 / 1" | bc)
    text="${pct}%"
else
    exit 1
fi

echo "$text"
echo "$text"
echo "#ffffff"
