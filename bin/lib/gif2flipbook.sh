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

    # sorry for these variables.
    # todo: make them more reabable.
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
            fi
        fi
    done
    GIFCOUNT=0
    for file in ${mfiles} ; do
        # need to do this again because first we needed to check max size
        # and max length.
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
                let GIFCOUNT++
            fi
        fi
    done

    echo "GIFS: ${GIFCOUNT}"
    internalGIFCOUNT=$((${GIFCOUNT} - 1))
    while [ ${maxframecount} -gt 0 ]; do
        inputs=""
        thisgifcount=0
        while [ ${thisgifcount} -le ${internalGIFCOUNT} ]; do
            inputs="${inputs} ${tmpdir}/${thisgifcount}_$(printf "%05d\n" ${maxframecount}).png"
            let thisgifcount++
        done
        gm montage +frame +shadow +label -geometry ${maxw}x${maxh}+100+100 -tile 2x3 ${inputs} "${psdir}/$( printf "%05d\n" ${count}).ps"
        echo "montage ${count}"
        let count++
        let maxframecount--
    done

    echo "gs pdfmaker"
    gs -o ${folder}/6up.ps -q -dNOPAUSE -dBATCH -sDEVICE=ps2write ${psdir}/*

fi