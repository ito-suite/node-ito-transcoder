#!/bin/bash

read -r address < "$1"

# phantom.js to make screen captures -> makes pdf for text recovery

phantomjs ../lib/webScreenshot.js "${address}" "${1%.*}" pdf
