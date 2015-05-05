#!/bin/bash

# get smallest size of all images

# resize all images with padding to smallest size

# resize all images to output size

# make rawvideo

ffmpeg -framerate 1/5 -i img%03d.png -c:v libx264 -vf "fps=25,format=yuv420p" out.mp4