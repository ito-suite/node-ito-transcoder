#!/bin/bash

ffmpeg -y -i $1 -loglevel error -metadata title="${title}" -metadata author="$3"  -f webm -c:a libvorbis -b:a 128k -c:v libvpx ${basics} ${buffbig} ${file}-720p.webm