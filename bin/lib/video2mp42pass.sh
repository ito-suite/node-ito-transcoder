#!/bin/bash

deinterlace="-vf yadif=1:-1:0"
format="mp4"

#todo:
for f in ${1}
do
    echo "Processing $f"
    ffmpeg -y -i ${f} -loglevel error -threads 0  \
 -vcodec libx264 -preset veryfast   \
 -vprofile high -b:v 18220k -maxrate 18220k -r 25 -pix_fmt yuv420p  \
 -pass 1 -an -f mp4 /dev/null

    echo "2nd Pass Beginning"
    ffmpeg -y -i ${f} -loglevel error -threads 0  \
 -vcodec libx264 -preset veryfast \
 -vprofile high -b:v 18220k -maxrate 18220k -r 25 -pix_fmt yuv420p \
 -acodec libfdk_aac -b:a 128k -pass 2 $deinterlace -f mp4 ${2}/1-bak.mp4
done
