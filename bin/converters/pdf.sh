#!/bin/bash


mkdir "${dir}/html/"
mkdir "${dir}/jpg/"

gm convert ${1}'[0]' -quality 92 -resize '512x512>'  -interlace plane -flatten -depth 8 ${file}-preview.jpg

gm convert ${1}'[0]' -auto-orient -depth 16 -filter lanczos -thumbnail '16384@' -gravity center -background black -extent '128x128'  -quality 92 -interlace plane -flatten -depth 8 "${file}-thumb.jpg"


# make an image preview of all pages for the thumbgif
pageNum=$(gs -q -dNODISPLAY -c "(${1}) (r) file runpdfbegin pdfpagecount = quit")

gs -q -dNOPAUSE -dBATCH -sDEVICE=jpeg -dFirstPage=1 -dLastPage=$pageNum -sOutputFile=${dir}/jpg/${base}-%09d.jpg -dJPEGQ=95 -r300 ${1} -c quit



# make an animated thumbgif of the whole document
gm convert ${dir}/jpg/${base}-*.jpg -delay 25 -loop 0 -filter lanczos -thumbnail '16384@' -gravity center -background black -extent '128x128' ${file}-thumb.gif

pdftohtml -p -c -nodrm -fmt jpg $1 ${dir}/html/${base}.html

