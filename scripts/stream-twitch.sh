#!/bin/sh
set -eu

if [ -n "$1" ]; then
    STREAM_KEY="$1"
elif [ -f ~/.twitch_stream_key ]; then
    STREAM_KEY="$(cat ~/.twitch_stream_key)"
fi

if [ -z "$STREAM_KEY" ]; then
    echo "Missing stream key!"
    exit 1
fi

# input resolution
CAPTURE_RESOLUTION="1920x1080"
# output resolution
# OUTPUT_RESOLUTION="960x540"
OUTPUT_RESOLUTION=$CAPTURE_RESOLUTION
# target FPS
FPS="30"
# i-frame interval, should be double of FPS,
GOP="60"
# max 6
THREADS="2"
# one of the many FFMPEG presets
PRESET="ultrafast"
# audio frequency, in hz
AUDIO_RATE="44100"
AUDIO_BITRATE="192k"
VIDEO_BITRATE_MIN="2000k"
VIDEO_BITRATE_MAX="3600k"
# twitch server in frankfurt, see http://bashtech.net/twitch/ingest.php for list
SERVER="live-ams"

ffmpeg -f x11grab -s $CAPTURE_RESOLUTION -r $FPS -i :0.0 -ar $AUDIO_RATE \
    -f alsa -i hw:1,0 -f flv -ac 2 -vcodec libx264 -g $GOP -keyint_min $FPS \
    -b:v $VIDEO_BITRATE_MAX -minrate $VIDEO_BITRATE_MIN -maxrate $VIDEO_BITRATE_MAX \
    -pix_fmt yuv420p -s $OUTPUT_RESOLUTION -preset $PRESET -tune film \
    -acodec aac -b:a $AUDIO_BITRATE -threads $THREADS -strict normal \
    -bufsize $VIDEO_BITRATE "rtmp://$SERVER.twitch.tv/app/$STREAM_KEY"
