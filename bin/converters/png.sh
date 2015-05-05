#!/bin/bash

gm convert $1'[0-1000]' -auto-orient -flatten -filter lanczos -resize '512x512>' -quality 95 -interlace plane -sampling-factor 1x1 +profile '!exif,*' "${file}-preview.jpg"
echo "Created preview image from ${1}"

gm convert $1'[0-1000]' -auto-orient -flatten -filter lanczos -thumbnail '16384@' -gravity center -background black -extent '128x128'  -quality 92 -interlace plane  -sampling-factor 1x1 +profile '*' "${file}-thumb.jpg"
echo "Created thumb image from ${1}"

gm convert $1'[0-1000]' -auto-orient -filter lanczos -resize '1920x1080>' "${file}-1080.png"
echo "Created 1080p image from ${1}"

gm convert $1'[0-1000]' -auto-orient -filter lanczos -resize '1280x720>' "${file}-720.png"
echo "Created 720p image from ${1}"
