#!/bin/bash

folder=${1}

if [ -d ${folder} ] ; then
    rm ${folder}/giflist.txt
    tmpdir="${folder}/tmp"
    psdir="${folder}/ps"
    rm -r ${tmpdir}
    rm -r ${psdir}
    itemcount=$(ls -1 "$folder" | wc -l)
    mkdir -p "${tmpdir}"
    mkdir -p "${psdir}"

    GIFCOUNT=0
    framecount=0
    count=0
    countee=0
    thisgifcount=0
    maxframecount=0
    maxw=0
    maxh=0
    mfiles=$(ls "$folder")

for file in ${mfiles} ; do
    if [ -d "$folder/$file" ]; then
        echo $file > /dev/null
    else
        #    îs it a gif?

        analyze=""
        firstframe=""
        filetype=""
        analyze=$(gm identify "$folder/$file" -format "|%m:%h:%w:%p")
        firstframe=$(echo ${analyze} | cut -d'|' -f2)
        filetype=$(echo ${firstframe} | cut -d':' -f1)

        if test "${filetype}" = GIF; then

        h=$(echo ${firstframe} | cut -d':' -f2)
        w=$(echo ${firstframe} | cut -d':' -f3)

        lastframe=${analyze##*|}
        framecount=${lastframe##*:}

        if [ ${framecount} -gt ${maxframecount} ] ; then
            maxframecount=${framecount}
        fi
        if [ ${h} -gt ${maxh} ] ; then
            maxh=${h}
        fi
        if [ ${w} -gt ${maxw} ] ; then
            maxw=${w}
        fi
#        gm identify "${file}" > ${tmpdir}/${GIFCOUNT}.frames


        fi
    fi
done
GIFCOUNT=0
    for file in ${mfiles} ; do
        if [ -d "$folder/$file" ]; then
            echo $file > /dev/null
        else
            #    îs it a gif?

            analyze=""
            firstframe=""
            filetype=""
            analyze=$(gm identify "$folder/$file" -format "|%m:%h:%w:%p")
            firstframe=$(echo ${analyze} | cut -d'|' -f2)
            filetype=$(echo ${firstframe} | cut -d':' -f1)

            if test "${filetype}" = GIF; then
                countee=0
                while [ ${countee} -lt ${maxframecount} ]
                do
                    gm convert -size ${maxw}x${maxw} xc:white  "${tmpdir}/${GIFCOUNT}_$(printf "%05d\n" ${countee}).png"
                    let countee++
                done


                gm convert "$folder/$file" -matte -coalesce -background white +adjoin -depth 8 "${tmpdir}/${GIFCOUNT}_%05d.png"

                echo "$folder/$file" >> ${folder}/giflist.txt
            GIFCOUNT=$(expr ${GIFCOUNT} \+ 1)
        fi
    fi
done

    echo "GIFS: ${GIFCOUNT}"
    internalGIFCOUNT=$((${GIFCOUNT} - 1))
    #thisframecount=$(( ${maxframecount} - 1 ))
   ### while [ ${count} -lt ${maxframecount} ]; do
    while [ ${maxframecount} -gt 0 ]; do
        inputs=""
        thisgifcount=0
        #while read line
        #do

        #   inputs="${inputs} ${line}[${count}]" this won't work cuz coalesce not available in montage.
        #   back to making individual pngs. :/

        #done < "${folder}/giflist.txt"
        while [ ${thisgifcount} -le ${internalGIFCOUNT} ]; do
            inputs="${inputs} ${tmpdir}/${thisgifcount}_$(printf "%05d\n" ${maxframecount}).png"
            let thisgifcount++
        done

        #echo ${inputs}
        #gm montage +frame +shadow +label -page A4 -resize 4960x7016 -geometry ${maxw}x${maxh}+100+100 -tile 2x3 ${inputs} "${psdir}/$( printf "%05d\n" ${count}).ps"
        gm montage +frame +shadow +label -geometry ${maxw}x${maxh}+100+100 -tile 2x3 ${inputs} "${psdir}/$( printf "%05d\n" ${count}).ps"
        echo "montage ${count}"
        let count++
        let maxframecount--
    done
    #count=1
    #while [ ${count} -le ${maxframecount} ]; do
    #    psinputs="${psinputs} ${psdir}/$( printf "%05d\n" ${count}).ps"
    #    let count++
    #done
    echo "gs pdfmaker"
    #psmerge -o${folder}/6up.ps ${psdir}/*
    gs -o ${folder}/6up.ps -q -dNOPAUSE -dBATCH -sDEVICE=ps2write ${psdir}/*
    #gs -o ${folder}/6up.pdf -q -dNOPAUSE -dBATCH -dPDFSETTINGS=/prepress -sDEVICE=pdfwrite ${psdir}/*
    #ps2pdf ${folder}/6up.ps ${folder}/6up.pdf
    #gm convert /home/egal/Desktop/gifflip_tests/gif-select-square-2/ps/*.ps /home/egal/Desktop/gifflip_tests/gif-select-square-2/6up_notprepress_fromgm.pdf
fi