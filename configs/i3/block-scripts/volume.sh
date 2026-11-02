#!/bin/sh

sink_emoji="🔊"

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

    btid=$(wpctl inspect @DEFAULT_AUDIO_SINK@ | grep "api.bluez5.address" | awk '{print $3}' | tr -d '"')
    if [ -n "$btid" ]; then
        btinfo=$(bluetoothctl info "$btid")
        if echo "$btinfo" | grep -q "Icon: audio-headphones"; then
            sink_emoji="🎧"
        elif echo "$btinfo" | grep -q "Icon: audio-headset"; then
            sink_emoji="🎧"
        fi
        btbat=$(echo "$btinfo" | grep -P "^\s*Battery Percentage" | awk '{print $4}' | tr -d '()')
        if [ $btbat -lt 25 ]; then
            btbat="🪫${btbat}"
        else
            btbat="🔋${btbat}"
        fi
    fi
fi

if [ -n "$btbat" ]; then
    echo "${sink_emoji} ${sink}  🎤 ${src}  ${btbat}%"
else
    echo "${sink_emoji} ${sink}  🎤 ${src}"
fi
echo "vol:${sink} mic:${src}"
echo "#ffffff"
