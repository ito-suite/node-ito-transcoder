#!/bin/bash

#pipe in a directory and do the work there.

if [[ ${2} ]]
    then
        size=${2}
    else
        size="1920x1080"
fi

cd "$1"

mkdir -p "${1}/web"

for fname in *
do
    if test -f "$fname"
    then
        # CHECK FOR FALSE CHARACTERS AND RENAME THE FILES.
        name="${fname%\.*}"
        extension="${fname#$name}"
        shopt -s extglob; newname=${name//+([^[:alnum:]])/_}
        newfname="$newname""$extension"
        if [ "$fname" != "$newfname" ]; then
            mv "$fname" "$newfname"
        fi
        echo "transcoding $newname"

        gm convert "$newfname[0-1000]" -auto-orient -flatten -depth 16  -filter lanczos -thumbnail "${size}" -gravity center -background black -extent "${size}" -depth 8 +profile '!exif,*' -quality 95 "./web/web-${newname}.jpg"
#-rotate 270
    fi
done

# name="ä=32bh-.txt"; newname=${name//+([^[:alnum:]])/_}; echo $newname