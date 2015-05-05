#!/bin/bash

ffmpeg -y -i $1 -loglevel error -metadata title="${title}" -metadata author="$3" -f mp4 -c:a libfdk_aac -b:a 128k -c:v libx264 ${basics} -vprofile main ${buffbig} ${tmp}/720p.mp4
