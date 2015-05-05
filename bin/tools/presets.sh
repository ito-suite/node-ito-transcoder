#!/bin/bash

if [[ $1 == "--help" ]]; then
    cat "dict/presets.json"
    exit
fi

parsePreset ()
{
    echo "$(grep "${preset[$i]}" "$section" | cut -d[ -f2 | cut -d'"' -f2)"
}

# this works to split out the presets and parse their values
countPRESETS=$(echo ${presets} | awk -F, {'print NF'})
i=1
while test $i -le ${countPRESETS}; do
    preset[$i]=$(echo ${presets} | cut -d, -f${i})
    case ${preset[$i]} in
        video*)
            section=$( awk '/video/,/}/' "dict/presets.json");
            # looks like ito.sh -f $file -p "

        ;;
        ffmpeg_*)
        # these are direct flags for the command line
        greppee=$(parsePreset)
        ffmpegPresets="${greppee} ${command}"
        ;;
    esac
    i=$(expr $i + 1)
done
echo "command: ${command}"
