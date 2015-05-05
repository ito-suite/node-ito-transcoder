#!/bin/bash

# usage
# ./thumb.sh "infile"

# lookup extent, background, quality in settings.json

gm convert "$1" -filter lanczos -thumbnail '16384@' -gravity center -background black -extent '128x128'  -quality 92 -interlace plane  -sampling-factor 1x1 +profile '*'  ${file}-thumb.jpg || echo "could not create thumb.jpg"
gm convert ${file}-thumb.jpg ${file}-thumb.gif || echo "could not create thumb.gif"
