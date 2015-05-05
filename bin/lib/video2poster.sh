#!/bin/bash

#######################################
# oculux make poster image
# poster.sh
#
# v.0.1
#
# $1 -> data-source
# $2 -> timestamp (00:00:00.0000)
#######################################

# screen display constants
big_width=1280
med_width=640
sml_width=480
thumb_width=90

# calculate the aspect ratio
d_aspect_ratio=$(ffprobe -show_streams $sourcefile 2>/dev/null | grep "display_aspect_ratio=" | cut -d'=' -f2)
width_ratio=$(echo $d_aspect_ratio | cut -d':' -f1)
height_ratio=$(echo $d_aspect_ratio | cut -d':' -f2)

# calculate the *_REAL_* height and width
big_height=$(expr $big_width / $width_ratio \* $height_ratio)
med_height=$(expr $med_width / $width_ratio \* $height_ratio)
sml_height=$(expr $sml_width / $width_ratio \* $height_ratio)
thumb_height=$(expr $thumb_width / $width_ratio \* $height_ratio)

ffmpeg -y -i "${1}" -loglevel error -ss $2 -f image2 -vframes 1 -r 1 -vf scale=${big_width}:${big_height} -an "${1%.*}poster-720p.png"

# this should automatically trigger the thumbnails and preview scripts
