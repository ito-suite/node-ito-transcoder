#!/bin/bash
# make it system agnostic

gm convert "${1}[0]"  -auto-orient -depth 16 -filter lanczos -resize '512x512>'  -background black -quality 92 -interlace plane -flatten -depth 8 "${1%.*}-preview.jpg"
