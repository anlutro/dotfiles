#!/bin/sh

if [ ! "$1" ]; then
	echo "Missing stream key!"
	exit 1
fi
STREAM_KEY="$1"

# input resolution
INRES="1920x1080"
# output resolution
OUTRES="960x540"
# target FPS
FPS="15"
# i-frame interval, should be double of FPS,
GOP="30"
# min i-frame interval, should be equal to FPS
GOPMIN="15"
# max 6
THREADS="2"
# constant bitrate (should be between 1000k - 3000k)
CBR="${2-1500k}"
# one of the many FFMPEG presets
QUALITY="ultrafast" 
AUDIO_RATE="44100"
# twitch server in frankfurt, see http://bashtech.net/twitch/ingest.php for list
SERVER="live-arn"

ffmpeg -f x11grab -s "$INRES" -r "$FPS" -i :0.0 -f alsa -i pulse -f flv -ac 2 \
	-ar $AUDIO_RATE -vcodec libx264 -g $GOP -keyint_min $GOPMIN -b:v $CBR \
	-minrate $CBR -maxrate $CBR -pix_fmt yuv420p -s $OUTRES -preset $QUALITY \
	-tune film -acodec libmp3lame -threads $THREADS -strict normal \
	-bufsize $CBR "rtmp://$SERVER.twitch.tv/app/$STREAM_KEY"
