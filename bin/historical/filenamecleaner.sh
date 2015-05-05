#!/bin/bash
# expects a filepath from $1
# changes the name if necessary
# pipes the name out to stdout
# actually we are using DETOX now

if test -f "$1"; then
    filename=$(basename "${1}")
    name=${filename%%.*} # check
    extension="${1#$name}"
    newname=${name//+([^[:alnum:]])/_}
    newfname="${newname}${extension}"
    if [ "$name" != "$newname" ]; then
        mv "$1" "$newname"
    fi
fi