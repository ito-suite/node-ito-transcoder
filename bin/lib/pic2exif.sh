#!/bin/bash

# export original exif data if available
gm convert "${1}" "${1%.*}.exif" 2>> "${1%.*}.log"

# write exif to log
exiftool "${1}" 2>/dev/null >> "${1%.*}.log"