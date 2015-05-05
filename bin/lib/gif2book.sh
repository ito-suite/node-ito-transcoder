#!/bin/bash

#usage
# $ gif2book.sh "~/giffolder"

folder=${1}

if [ -d ${folder} ] ; then


tmpdir="${folder}/tmp"
psdir="${folder}/ps"
rm -r ${tmpdir}
rm -r ${psdir}
itemcount=$(ls -1 "$folder" | wc -l)
mkdir -p "${tmpdir}"
mkdir -p "${psdir}"

GIFCOUNT=0
framecount=0

# PREP THAT SHIT
for f in "${folder}/*.gif"; do
    let GIFCOUNT=GIFCOUNT+1
    GIFCOUNT=$(expr ${GIFCOUNT} \+ 1)

    analyze=""
    firstframe=""
    filetype=""
    analyze=$(gm identify "${f}" -format "|%m:%h:%w:%p")
    firstframe=$(echo ${analyze} | cut -d'|' -f2)
    filetype=$(echo ${firstframe} | cut -d':' -f1)

    h=$(echo ${firstframe} | cut -d':' -f2)
    w=$(echo ${firstframe} | cut -d':' -f3)

    lastframe=${analyze##*|}
    framecount=${lastframe##*:}

    #if test "${filetype}" = GIF; then#

#        h=$(echo ${firstframe} | cut -d':' -f2)
#        w=$(echo ${firstframe} | cut -d':' -f3)#

#        lastframe=${analyze##*|}
 #       framecount=${lastframe##*:}
        # a4
        # -geometry 256x192+100+50 -gravity west
        # -page A4 -resize 4960x7016
        #gm convert "$f" -matte -coalesce +adjoin -depth 8 "${tmpdir}/${GIFCOUNT}_%05d.png"
        #echo "gm convert $f -matte -coalesce +adjoin -depth 8 ${tmpdir}/${GIFCOUNT}_%05d.png"
        #echo $f
  #  fi
done

    if [ ${itemcount} -lt 1 ]; then
        echo "No gif found"
        exit
    fi

    echo "GIFS: ${itemcount}"
    echo "FRAMES: ${framecount}"
    echo "X: ${w}"
    echo "Y: ${h}"



    while read line
    do
        value=`expr $value + 1`;
        echo $value;
    done < "myfile"



    count=1
    while [ ${count} -lt ${framecount} ]; do
        inputs=""
        for i in ${itemcount}; do
            inputs="${inputs} ${tmpdir}/${i}_$( printf "%05d\n" ${count}).png"
        done
        #gm montage +frame +shadow +label -page A4 -resize 4960x7016 -geometry ${w}x${h}+100+100 -tile 2x3 ${inputs} "${psdir}/$( printf "%05d\n" ${count}).ps"
        let count=count+1
     #   echo $inputs

    done

    # compose only seems to accept three inputs. :(

    #gm composite -compose over -page A4 -geometry +300+50 "${tmpdir}/1_00001.miff" -compose over -geometry +2780+50 "${tmpdir}/1_00002.miff"  -compose over -geometry +300+2390 "${tmpdir}/1_00003.miff" "${tmpdir}/../giphy_composite.ps"
   # gm montage +frame +shadow +label -page A4 -resize 4960x7016 -geometry 256x192+100+100 -tile 2x6 "${tmpdir}/1_00001.png" "${tmpdir}/1_00002.png" "${tmpdir}/1_00003.png" "${tmpdir}/1_00004.png" "${tmpdir}/1_00005.png" "${tmpdir}/1_00006.png" "${tmpdir}/../giphy.ps"

    #gm convert "$1" "${tmpdir}/../giphy.pdf"

#     gm montage -geometry 256x192+10+10 -bordercolor red birds.* montage.miff


fi # end is dir