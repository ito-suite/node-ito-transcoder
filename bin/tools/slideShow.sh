#!/bin/bash

#pipe in a directory and do the work there.
# todo: vet this!

cd "$1"

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

        # make our randomness
        randSize=$(( ( RANDOM % 10 )  + 100 ))
        randSizeW=$(( ( RANDOM % 10 )  + 1920 ))
        randSizeH=$(( ( RANDOM % 10 )  + 1080 ))
        randLeft=$(( ( RANDOM % 10 )  - 20 ))
        randRight=$(( ( RANDOM % 10 )  - 20 ))
#        random="0=0,0:1920x1080;"
        random="0=0,0:100%x100%;149=0,0:${randSize}%x${randSize}%"
        ###  -attach affine  transition.geometry=${random}
        ###  use-profile=1

        ### -attach crop center=1 -attach affine transition.fill=1 transition.scale=1 transition.height=1080 transition.width=1920 transition.cycle=225 transition.geometry='1920x1080' transition.geometry=${random}

        CL="${CL} ${newfname} out=250 -filter luma cycle=50 duration=100"
    fi
done

melt ${CL} -consumer avformat:test2.mp4 height=720 width=1080

#melt *.jpg ttl=75 -attach crop center=1 -attach affine transition.cycle=225 transition.geometry="0=0,0:100%x100%;74=-100,-100:120%x120%;75=-60,-60:110%x110%;149=0:0:110%x110%;150=0,-60:110%x110%;224=-60,0:110%x110%" -filter luma cycle=75 duration=25 -track demo/music1.ogg -transition mix -consumer avformat:test.mp4

# melt TheCurator_Adjust_web_5x.mp4 TheCurator_Drop_web_5x.mp4 TheCurator_Setting_web_5x.mp4 -consumer avformat:TheCurator_web_5x.mp4 vcodec=libx264 movflags=faststart
