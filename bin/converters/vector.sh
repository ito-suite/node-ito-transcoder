#!/bin/bash

ps2pdf $1 ${file}.pdf

gm convert ${file}.pdf -auto-orient -flatten -filter lanczos -resize '512x512>' -quality 95 -interlace plane -sampling-factor 1x1 +profile '!exif,*' "${file}-preview.jpg"

gm convert ${file}-preview.jpg -depth 16 -filter lanczos -thumbnail '16384@' -gravity center -background black -extent '128x128'  -quality 92 -interlace plane -depth 8 "${file}-thumb.jpg"

pdf2svg ${file}.pdf ${file}-rendered.svg