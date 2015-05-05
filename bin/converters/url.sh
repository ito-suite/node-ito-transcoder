#!/bin/bash

. $DIR/lib/./url2png.sh "${ACTIVEFILE}" || Error "url2png.sh"
Register "${file}.png"

. $DIR/lib/./url2pdf.sh "${ACTIVEFILE}" || Error "url2pdf.sh"
Register "${file}.pdf"

. $DIR/lib/./pic2preview.sh "${file}.png" || Error "pic2preview.sh"
Register "${file}-preview.jpg"

. $DIR/lib/./pic2thumb.sh "${file}.png" || Error "pic2thumb.sh"
Register "${file}-thumb.jpg"

