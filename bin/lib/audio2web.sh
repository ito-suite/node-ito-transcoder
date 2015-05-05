#!/bin/bash

# mp3
sox $1 -V "${1%.*}-transcoded.mp3" 2>> "${1%.*}.log"

# wav
sox $1 -V --norm=-3 "${1%.*}-transcoded.wav" 2>> "${1%.*}.log"

# ogg
sox $1 -V "${1%.*}-transcoded.ogg" 2>> "${1%.*}.log"

