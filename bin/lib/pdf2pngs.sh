#!/bin/bash

# set quality if called with it
if test $2; then
    quality=$2
else
    quality=90
fi

# make an image preview of all pages for the thumbgif
pageNum=$(gs -q -dNODISPLAY -c "(${1}) (r) file runpdfbegin pdfpagecount = quit")

gs -q -dSAFER -dNOPAUSE -dBATCH -sDEVICE=png16m -dFirstPage=1 -dLastPage=$pageNum -sOutputFile=${tmp}/jpg/${base}-%09d.png -r${quality} ${1} -c quit