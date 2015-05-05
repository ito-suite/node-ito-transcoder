#!/bin/bash

# this injects any values into exif
# use $1 for file and $2

email="me@you.com"

#example:
exiftool "$1" -Software='ITO' -Contact="$email" -Copyright='No copyright claim made. This capture was made for Archival Reference by ITO.' -Subject="CAPTURE TIME: $capturetime" -overwrite_original