#!/bin/bash

# would be good to know the file type and then extrapolate preferred extension.



for file in $@
    do
        string=$(echo ${string} "${file}")
    done

melt ${string} -consumer avformat:output.mp4