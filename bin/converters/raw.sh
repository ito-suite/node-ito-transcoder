#!/bin/bash


# ufraw uses dcraw and that evilly monstrout lensfun
ufraw-batch --overwrite --auto-crop --lensfun=auto --wb=camera --restore=hsv --base-curve=camera --out-type=jpg $1

gm convert ${file}.jpg "${file}.exif"
echo "Created original exif from ${1}"

gm convert ${file}.jpg -auto-orient -flatten -depth 16 -filter lanczos -resize '512x512>' -quality 95 -interlace plane -sampling-factor 1x1 -depth 8 +profile '!exif,*' "${file}-preview.jpg"
echo "Created preview image from ${1}"

# fix up the exif information
gm convert ${file}.jpg -auto-orient -flatten -depth 16 -filter lanczos -thumbnail '16384@' -gravity center -background black -extent '128x128'  -quality 92 -interlace plane  -sampling-factor 1x1 -depth 8 +profile '*' "${file}-thumb.jpg"
echo "Created thumb image from ${1}"

# make four sizes
# keep the exif info > +profile '!exif,*'

gm convert ${file}.jpg -auto-orient -flatten -depth 16  -filter lanczos -resize '1920x1080>' -quality 95 -interlace plane -sampling-factor 1x1 -depth 8 +profile '!exif,*' "${file}-1080.jpg"
echo "Created 1080p image from ${1}"

gm convert ${file}.jpg -auto-orient -flatten -depth 16 -filter lanczos -resize '1280x720>' -quality 95 -interlace plane -sampling-factor 1x1 -depth 8 +profile '!exif,*' "${file}-720.jpg"
echo "Created 720p image from ${1}"
