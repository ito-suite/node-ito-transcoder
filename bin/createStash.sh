#!/bin/sh

# this script creates a local stash for pinned versions of various repos
# it will be hosted at our build server
# the reason for this is that many of the repo servers are just SLOW slow slow.

sudo apt-get install mercurial git

# this takes forever -> disown it.
wget ftp://ftp.graphicsmagick.org/pub/GraphicsMagick/GraphicsMagick-LATEST.tar.gz & disown

hg clone http://hg.videolan.org/x265
git clone https://github.com/Kitware/CMake.git
git clone https://github.com/pornel/pngquant.git
git clone https://github.com/ariya/phantomjs.git
git clone https://github.com/dagwieers/unoconv.git

git clone --depth 1 git://git.videolan.org/x264.git
git clone --depth 1 git://git.code.sf.net/p/opencore-amr/fdk-aac
git clone -b experimental http://git.chromium.org/webm/libvpx.git
git clone --depth 1 git://git.videolan.org/ffmpeg.git
git clone https://chromium.googlesource.com/webm/libwebp

wget http://sourceforge.net/projects/libpng/files/latest/download
mv download libpng.tar.gz
wget http://sourceforge.net/project/ufraw/files/latest/download
mv download ufraw.tar.gz
wget http://sourceforge.net/project/lame/files/latest/download
mv download lame.tar.gz
wget http://sourceforge.net/projects/clamav/files/latest/download
mv download clamav.tar.gz
wget http://sourceforge.net/projects/lcms/files/latest/download
mv download lcms.tar.gz

wget http://www.tortall.net/projects/yasm/releases/yasm-1.2.0.tar.gz
wget http://downloads.xiph.org/releases/opus/opus-1.0.3.tar.gz
wget http://zlib.net/zlib-1.2.8.tar.gz
wget http://www.ece.uvic.ca/~frodo/jasper/software/jasper-1.900.1.zip
wget http://rsmith.home.xs4all.nl/files/py-stl-3.1.zip
wget wget http://www.cs.princeton.edu/~min/meshconv/linux64/meshconv
