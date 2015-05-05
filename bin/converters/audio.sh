#!/bin/bash

. $DIR/lib/./audio2spectrogram.sh "${ACTIVEFILE}" || Error "audio2spectrogram.sh"
Register "${file}-spectrogram.png"

. $DIR/lib/./audio2web.sh "${ACTIVEFILE}" || Error "audio2web.sh"
Register "${file}-transcoded.mp3"
Register "${file}-transcoded.wav"
Register "${file}-transcoded.ogg"


. $DIR/lib/./pic2preview.sh "${file}-spectrogram.png" || Error "pic2preview.sh"
Register "${file}-preview.jpg"

. $DIR/lib/./pic2thumb.sh "${file}-spectrogram.png" || Error "pic2thumb.sh"
Register "${file}-thumb.jpg"
