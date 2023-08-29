#!/bin/sh

if command -v wpctl >/dev/null 2>&1; then
    sink_volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2}')
    sink_pct=$(echo "$sink_volume * 100 / 1" | bc)
    src_volume=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | awk '{print $2}')
    src_pct=$(echo "$src_volume * 100 / 1" | bc)
else
    exit 1
fi

echo "🔊 ${sink_pct}%  🎤 ${src_pct}%"
echo "🔊 ${sink_pct}%  🎤 ${src_pct}%"
echo "#ffffff"
