#!/bin/bash

#pipe in a directory and do the work there.

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

        ffmpeg -y -i "$newfname" -f mp4 -c:a libfdk_aac -b:a 128k -c:v libx264 -qmin 2 -qmax 18 -vprofile baseline -threads 0  -force_key_frames 00:00:00.000 -pix_fmt yuv420p -movflags faststart -vf "scale=640:trunc(ow/a/2)*2" "./web/web-${newname}.mp4"

    fi
done
