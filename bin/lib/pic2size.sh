#!/bin/bash

if [[ ${2} ]]
then
    size=${2}
else
    size="1920x1080"
fi

gm convert "$1[0-1000]" -auto-orient -flatten -depth 16  -filter lanczos -resize "${size}"\> -quality 92 -interlace plane -sampling-factor 1x1 -depth 8 +profile '!exif,*' "${1%.*}-size.jpg"