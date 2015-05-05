#!/bin/bash

# we are using the mp4 / aac codec for flv

# we could just bootstrap this onto the mp4 lib with -c:a copy & -c:v copy
# as in: look for an mp4 video, if it exists copy the codecs, otherwise
# reencode

ffmpeg -y -i $1 -loglevel error -metadata title="${title}" -metadata author="$3"  -c:a libvorbis -b:a 128k -c:v libtheora ${basics} ${buffbig}  -f flv ${file}-720p.flv