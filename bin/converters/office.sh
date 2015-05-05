#!/bin/bash

mkdir "${dir}/html/"
mkdir "${dir}/jpg/"

# make a pdf version for subsequent processing and as download
unoconv -f pdf $1

gm convert ${file}.pdf'[0]' -quality 92 -resize '512x512>' ${file}-preview.jpg
# make a thumbnail jpg of the first page
gm convert  ${file}.pdf'[0]' -auto-orient -depth 16 -filter lanczos -thumbnail '16384@' -gravity center -background black -extent '128x128'  -quality 92 -interlace plane -flatten -depth 8 "${file}-thumb.jpg"

# make an html version of the page for online viewing
pdftohtml -p -c -nodrm -fmt jpg ${file}.pdf ${dir}/html/${base}.html

# clean out the empty space to shrink the file size by about 30%
for f in ${dir}/html/*.html; do
    sed 's/&#160;/ /g' ${f} > ${f}.bak
    mv ${f}.bak ${f}
done

# make an image preview of all pages for the thumbgif
pageNum=$(gs -q -dNODISPLAY -c "(${file}.pdf) (r) file runpdfbegin pdfpagecount = quit")
gs -q -dNOPAUSE -dBATCH -sDEVICE=jpeg -dFirstPage=1 -dLastPage=$pageNum -sOutputFile=${dir}/jpg/${base}-%09d.jpg -dJPEGQ=90 -r90 ${file}.pdf -c quit

# make an animated thumbgif of the whole document
gm convert ${dir}/jpg/${base}-*.jpg -delay 25 -loop 0 -filter lanczos -thumbnail '16384@' -gravity center -background black -extent '128x128' ${file}-thumb.gif
rm -r ${dir}/jpg/
