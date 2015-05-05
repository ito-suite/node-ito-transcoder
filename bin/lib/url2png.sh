#!/bin/bash

read -r address < "$1"

# phantom.js to make screen captures -> makes png at $file.png cuz resolution.

phantomjs ./lib/webScreenshot.js "${address}" "${1%.*}" png

