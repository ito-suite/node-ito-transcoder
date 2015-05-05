#!/bin/bash

als $1 -l > ${dir}/html/${base}.txt
sed "1s/.*/Archive: ${base}.${extension}/" ${dir}/html/${base}.txt > ${dir}/html/${base}.html
arepack $1 ${file}.zip
unoconv -f pdf ${dir}/html/${base}.html
mv ${dir}/html/${base}.pdf ${dir}/${base}.pdf