#!/bin/bash

# make sure that the vars are set -> requires ito.sh
SetFileVars

count=$(echo ${detectline} | awk -F, {'print NF'})
echo "${PACKAGE} v${VERSION}">  ${file}.detect
echo "DATE: ${date}" >> ${file}.detect
echo "PATH: ${holder}/${base}.${extension}"  >> ${file}.detect
echo "" >> ${file}.detect
echo "" >> ${file}.detect
echo "" >> ${file}.detect
i=1
while test $i -le $count
do
    str[$i]=$(echo ${detectline} | cut -d, -f${i})
        case ${str[$i]} in
            exiftool*)
                echo ${str[$i]} >> ${file}.detect
                command=$(echo ${str}[$i] | cut -d= -f2)
                if test ${command}; then
                    exiftool "${fullfile}" "${command}" 2>/dev/null >> ${file}.detect
                else
                    exiftool "${fullfile}" 2>/dev/null >> ${file}.detect
                fi
                echo "" >> ${file}.detect
                # remove directory listing from exiftool
                sed -i '/Directory/d' ${file}.detect
            ;;
            gmidentify*)
                echo ${str[$i]} >> ${file}.detect
                echo "========" >> ${file}.detect
                command=$(echo ${str}[$i] | cut -d= -f2)
                if test ${command}; then
                    gm identify "${fullfile}" "${command}" 2>/dev/null >> ${file}.detect
                else
                    gm identify "${fullfile}" 2>/dev/null >> ${file}.detect
                fi
                echo "" >> ${file}.detect
            ;;
            mplayer*)
                echo ${str[$i]} >> ${file}.detect
                echo "========" >> ${file}.detect
                command=$(echo ${str}[$i] | cut -d= -f2)
                if test ${command}; then
                    mplayer -really-quiet -vo null -ao null -frames 0 -identify ${command} "${fullfile}" 2>/dev/null >> ${file}.detect
                else
                    mplayer -really-quiet -vo null -ao null -frames 0 -identify "${fullfile}" 2>/dev/null >> ${file}.detect
                fi
                echo "" >> ${file}.detect
            ;;
            ffprobe*)
                echo ${str[$i]} >> ${file}.detect
                echo "========" >> ${file}.detect
                ffprobe -show_streams -i "${fullfile}" 2>/dev/null >>  ${file}.detect
                echo "" >> ${file}.detect
                # cleanup ffprobe output
                sed -i '/ffprobe version/d' ${file}.detect
                sed -i '/  lib/d' ${file}.detect
                sed -i '/  built on/d' ${file}.detect
                sed -i '/  configuration:/d' ${file}.detect
            ;;
            mime*)
                echo ${str[$i]} >> ${file}.detect
                echo "========" >> ${file}.detect
                mime=$(getMimeType)
                echo "${mime}" >> ${file}.detect
                echo "" >> ${file}.detect
            ;;
            lesspipe*)
                echo ${str[$i]} >> ${file}.detect
                echo "========" >> ${file}.detect
                lesspipe ${fullfile} >> ${file}.detect
                echo "" >> ${file}.detect
            ;;
            *)

            ;;
        esac
    i=$(expr $i + 1)
done
# rewrite the directory everywhere to be less absolute [fs.SEC]
sed -i "s@${fullfile}@${holder}/$(basename ${ACTIVEFILE})@g" ${file}.detect
