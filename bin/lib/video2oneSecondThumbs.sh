#!/bin/bash

# this would be to show a thumbnail for every one second of video
# as in a preview. however, mplayer might be better for this.

ffmpeg -i $1 -f image2 -vf fps=fps=1 out%d.png