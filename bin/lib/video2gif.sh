#!/bin/bash

# makes a gif from video at image changes

ffmpeg -y -i $1 -loglevel error -f image2 -vf "select=gt(scene\,0.1),scale=${thumb_width}:${thumb_height}" -frames:v 25 -vsync 0 -an ${tmp}/img%05d.png

gm convert -delay 25 -loop 0 ${tmp}/img*.png -depth 16 -filter lanczos -thumbnail '128x128' -gravity center -background black -extent '128x128' -depth 8 ${file}-thumb.gif