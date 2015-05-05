#!/bin/bash

mkdir "${dir}/html/"
mkdir "${dir}/jpg/"

als $1 -l > ${dir}/html/${base}.txt
#sed "1d" ${dir}/html/${base}.txt > ${dir}/html/${base}.html
sed "1s/.*/Archive: ${base}.${extension}/" ${dir}/html/${base}.txt > ${dir}/html/${base}.html
rm ${dir}/html/${base}.txt

arepack $1 ${file}.zip
#md5sum --tag ${file}.zip > ${file}.md5
#sha1sum --tag ${file}.zip > ${file}.sha1

unoconv -f pdf ${dir}/html/${base}.html
mv ${dir}/html/${base}.pdf ${dir}/${base}.pdf

pageNum=$(gs -q -dNODISPLAY -c "(${dir}/${base}.pdf) (r) file runpdfbegin pdfpagecount = quit")
gs -q -dNOPAUSE -dBATCH -sDEVICE=jpeg -dFirstPage=1 -dLastPage=$pageNum -sOutputFile=${dir}/jpg/${base}-%09d.jpg -dJPEGQ=90 -r90 ${dir}/${base}.pdf -c quit

gm convert  ${dir}/${base}.pdf'[0]' -auto-orient -flatten -filter lanczos -resize '512x512>' -quality 95 -interlace plane -sampling-factor 1x1 +profile '!exif,*' "${file}-preview.jpg"

# make a thumbnail jpg of the first page
gm convert  ${dir}/${base}.pdf'[0]' -auto-orient -depth 16 -filter lanczos -thumbnail '16384@' -gravity center -background black -extent '128x128'  -quality 92 -interlace plane -flatten -depth 8 "${file}-thumb.jpg"

# make an animated thumbgif of the whole document
gm convert ${dir}/jpg/${base}-*.jpg -delay 25 -loop 0 -filter lanczos -thumbnail '16384@' -gravity center -background black -extent '128x128'  ${file}-thumb.gif