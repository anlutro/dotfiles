#!/bin/sh

if command -v wpctl >/dev/null 2>&1; then
    wpctl_sink=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
    if echo "$wpctl_sink" | grep -q "MUTE"; then
        sink="mute"
    else
        sink_volume=$(echo "$wpctl_sink" | awk '{print $2}')
        sink="$(echo "$sink_volume * 100 / 1" | bc)%"
    fi
    wpctl_source=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@)
    if echo "$wpctl_source" | grep -q "MUTE"; then
        src="mute"
    else
        src_volume=$(echo "$wpctl_source" | awk '{print $2}')
        src="$(echo "$src_volume * 100 / 1" | bc)%"
    fi
fi

echo "🔊 ${sink}  🎤 ${src}"
echo "🔊 ${sink}  🎤 ${src}"
echo "#ffffff"
