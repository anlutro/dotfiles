#!/bin/sh

card_path="/sys/class/drm/card0/"
audio_output=""

for output in $(cd "$card_path" && echo card*); do
    out_status=$(<"$card_path"/"$output"/status)
    if [ "$out_status" = 'connected' ]; then
        echo "$output connected"
        case "$output" in
            "card0-HDMI-A-1")
                audio_output="hdmi-stereo" # Digital Stereo (HDMI 1)
         ;;
            "card0-HDMI-A-2")
                audio_output="hdmi-stereo-extra1" # Digital Stereo (HDMI 2)
         ;;
        esac
    fi
done
if [ -n "$audio_output" ]; then
    echo "selecting output $audio_output"
    pactl set-card-profile 0 output:$audio_output
fi
