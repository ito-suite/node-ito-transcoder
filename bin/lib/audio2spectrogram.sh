#!/bin/bash

# basic spectrogram
# creates ${file}-spectrogram.png

sox "$1" -n spectrogram -o "${tmp}/waveform.png" -x 1024 -y 257 -r -p 6 -h -m -a
gm convert "${tmp}/waveform.png" -flip -crop 1024x257 "${tmp}/waveform-bot.png"
gm convert "${tmp}/waveform.png" -crop 1024x257 "${tmp}/waveform-top.png"
gm montage "${tmp}/waveform-top.png" "${tmp}/waveform-bot.png" -tile 1x2 -mode Concatenate  "${file}-spectrogram.png"