#!/bin/bash

# should accept a folder

gm convert ${dir}/jpg/${base}-*.jpg -delay 25 -loop 0 -filter lanczos -thumbnail '128x128' -gravity center -background black -extent '128x128' ${1%.*}-thumb.gif