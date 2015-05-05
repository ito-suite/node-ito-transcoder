#!/bin/bash

# this is to dump every frame of a video into images.
# it can CREATE HUGE AMOUNTS OF DATA

ss=$2 # e.g. 00:02:04.1
vframes=$3 # eg 100

ffmpeg -ss $2 -i $1 -f image2 -vframes $vframes frame-%09d.png