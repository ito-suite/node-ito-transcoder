#!/bin/bash

gm convert $1'[0-1000]' -auto-orient -flatten -filter lanczos -resize '512x512>' -quality 95 -interlace plane -sampling-factor 1x1 "${file}-preview.jpg"
echo "Created preview image from ${1}"

gm convert $1'[0-1000]' -auto-orient -flatten -filter lanczos -thumbnail '16384@' -gravity center -background black -extent '128x128'  -quality 92 -interlace plane  -sampling-factor 1x1 +profile '*' "${file}-thumb.jpg"
echo "Created thumb image from ${1}"




analyze=$(gm identify "${1}" -format "|%m:%h:%w:%p")
firstframe=$(echo $analyze | cut -d'|' -f2)
filetype=$(echo $firstframe | cut -d':' -f1)

if [ $filetype = "GIF" ]
then

    base=$(basename $1)
    base="${base%.*}"
    dir=$(dirname $1)
    tmpdir="${dir}/${base}"
    mkdir "${tmpdir}"

    h=$(echo $firstframe | cut -d':' -f2)
    w=$(echo $firstframe | cut -d':' -f3)

    lastframe=${analyze##*|}
    framecount=${lastframe##*:}
    framecountpadded=$(echo "$framecount + 2.5" |bc -l)

    echo "$(gm identify -verbose ${1}[0])" > "${tmpdir}-gm.log"
    framedelay=$(cat "${tmpdir}-gm.log" | grep "Delay")
    compose=$(cat "${tmpdir}-gm.log" | grep "Compose")
    dispose=$(cat "${tmpdir}-gm.log" | grep "Dispose")
    background=$(cat "${tmpdir}-gm.log" | grep "Background Color")

    framedelay=${framedelay##* }

    framerate=$(echo "1 / $framedelay * 100" |bc -l)
    framerate=$(printf "%.1f" $framerate)

    background=${background##* }

    duration=$(echo "$framedelay / 100 * $framecountpadded" |bc -l)
    duration=$(printf "%.2f" $duration)

    crop=0
    # we need to make sure that the gif does not have any odd dimensions like 151x144 > make it into 150x144
    h_even=$(( $h % 2 ))
    if [ $h_even -eq 0 ]
    then
        trimheight=${h}
    else
        trimheight=$(echo "$h - 1" |bc -l)
        crop=1
    fi
    w_even=$(( $w % 2 ))
    if [ $w_even -eq 0 ]
    then
        trimwidth=${w}
    else
        trimwidth=$(echo "$w - 1" |bc -l)
        crop=1
    fi

    gm convert  "$1" -matte -coalesce +adjoin  -depth 8 "${tmpdir}/%05d.png"
    if (( $crop == 1 ))
    then
        gm mogrify -crop "${trimwidth}x${trimheight}+0+0" "${tmpdir}/*.png"
    fi

    ffmpeg -loglevel error -y -ar 48000 -ac 2 -f s16le -i /dev/zero -r ${framerate}/1 -f image2 -i "${tmpdir}/%05d.png" -c:a libfdk_aac -c:v libx264 -vf "fps=fps=25,format=pix_fmts=yuv420p" -t $duration "${dir}/${base}-tmp.mp4"
    qt-faststart "${dir}/${base}-tmp.mp4" "${dir}/${base}.mp4"

    rm "${dir}/${base}-tmp.mp4"


fi

#    show us what it discovered
#    echo framedelay: $framedelay
#    echo compose:    $compose
#    echo dispose:    $dispose
#    echo background: $background
#    echo framecount: $framecount
#    echo framerate:  $framerate frames / second
#    echo duration:   $duration seconds
#    echo height:     $h
#    echo width:      $w

rm -r "${tmpdir}"

