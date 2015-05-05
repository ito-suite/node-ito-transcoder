#!/bin/bash

begin=$(date +%s)
date=$(date)
PWD=$(pwd)
#GET THE REAL BIN DIRECTORY TO
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
    DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
PACKAGE=$(grep 'command'  "$DIR/../package.json" | cut -d'"' -f4)
VERSION=$(grep 'version'  "$DIR/../package.json" | cut -d'"' -f4)
DESCRIPTION=$(grep 'description'  "$DIR/../package.json" | cut -d'"' -f4)
CONTACT=$(grep 'author' "$DIR/../package.json" | cut -d'"' -f4)


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

         . ${DIR}/../lib/./raw2tif.sh "$newfname"
#        gm convert "$newfname[0-1000]" -auto-orient -flatten -depth 16  -filter lanczos -resize "${size}"\> -depth 8 +profile '!exif,*' -quality 95 "./web/web-${newname}.jpg"

    fi
done

