#!/bin/bash

for file in $@
    do
        string=$(echo ${string} "${file}")
    done

melt ${string} -consumer avformat:output.mp4