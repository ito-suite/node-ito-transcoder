#!/bin/bash

#1 collect inputs
# can have multiple inputs?
# > yes then gather


#3 create main output type
# 1 image
# 2 video
# 3 audio
# 4 html
# 5 pdf
# 6


#This is the list of sources

#these come from ito.sh
#begin=$(date +%s)
#date=$(date)

# the following is from setFileVars
#assume $1 = /home/web/app/uploads/_id/file.TYPE
#ACTIVEFILE=${1} # -> /home/web/app/uploads/_id/file.TYPE
#file="${ACTIVEFILE%.*}" # -> /home/web/app/uploads/_id/file
#base="${base%.*}" # -> file
#holder=$(echo ${ACTIVEFILE} | cut -d/ -f${last}) # -> _id
#dir=$(dirname ${ACTIVEFILE}) # -> /home/web/app/uploads/_id
#extensionBIG=${ACTIVEFILE##*.} # -> TYPE
#extension=$(echo ${extensionBIG} | awk '{print tolower($0)}') # -> type

#tmp=$(dirname ${ACTIVEFILE})"/${base}_tmp" # -> /home/web/app/uploads/_id/file_tmp
#mkdir -p ${tmp} # -> /home/web/app/uploads/_id/file_tmp

#PROGRESSFILE="${tmp}/${base}.progress"  # -> /home/web/app/uploads/_id/file_tmp/file.progress

#/home/web/app/uploads/_id/file.register > add files