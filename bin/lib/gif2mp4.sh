#!/bin/bash

# gif2mp4
# v0.5
# convert a gif to an h264 mp4 with 1/4 the size.
# based on ARCHIVITEKT TRANSCODING SYSTEM
# Max: 99999 frames. (Gifs that have more frames are just silly.)

# CHANGELOG
# v0.4 > added ffmpeg qt-quickstart to help the video get started even faster.
# v0.3 > added padding on duration
# v0.2 > removed all dependencies other than gm, ffmpeg and bash tools
# v0.1 > working system

# CLI usage of the result: mplayer -fs -vo xv 1.mp4 -loop 0

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
	# what if there is no fucking framerate???
	# make framerate 25
    framerate=10
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

    # added -tune fastdecode -tune zerolatency -profile:v baseline
    # for compatibility and faster playback at the cost of quality
    # but because this is gif that's ok.

    ffmpeg -loglevel error -y -ar 48000 -ac 2 -f s16le -i /dev/zero -r ${framerate}/1 -f image2 -i "${tmpdir}/%05d.png" -c:a libfdk_aac -c:v libx264 -vf "fps=fps=25,format=pix_fmts=yuv420p" -tune fastdecode -tune zerolatency -profile:v baseline -t $duration "${dir}/${base}-tmp.mp4"
    qt-faststart "${dir}/${base}-tmp.mp4" "${dir}/${base}.mp4"

    rm "${dir}/${base}-tmp.mp4"

    echo "Not a gif"
    exit 1
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
exit
