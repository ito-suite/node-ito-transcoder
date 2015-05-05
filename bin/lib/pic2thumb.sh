#!/bin/bash

gm convert ${1}[0] -auto-orient -depth 16 -filter lanczos -thumbnail '128x128' -gravity center -background black -extent '128x128'  -quality 92 -interlace plane -flatten -depth 8 "${1%.*}-thumb.jpg"