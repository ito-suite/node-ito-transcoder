#!/bin/bash

ffmpeg -y -i $1 -loglevel error -metadata title="${title}" -metadata author="$3"  -c:a libvorbis -b:a 128k -c:v libtheora ${basics} ${buffbig} ${file}-720p.ogv