#!/bin/bash

size="1920x1080"

. $DIR/lib/pic2exif.sh "${ACTIVEFILE}" || Error "pic2exif.sh"
Register "${file}.exif"

. $DIR/lib/./pic2preview.sh "${ACTIVEFILE}" || Error "pic2preview.sh"
Register "${file}-preview.jpg"

. $DIR/lib/./pic2thumb.sh "${ACTIVEFILE}" || Error "pic2thumb.sh"
Register "${file}-thumb.jpg"

. $DIR/lib/./pic2size.sh "${ACTIVEFILE}" ${size} || Error "pic2size.sh"
Register "${file}-size.jpg"
