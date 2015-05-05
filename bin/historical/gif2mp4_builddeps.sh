#!/bin/bash

# Install deps for gif2mp4 (enhanced for other transcoding purposes)
# OLIMEX A20 EDITION (w/Ubuntu Helper for Testing)
# basically we need a build environment, libpng, graphicsmagick & ffmpeg w/h264 & 


# Checking Permissions
Permission=$(id -u)

# Exit if not being run as Sudo
if [ $Permission -ne 0 ] 
then
  echo -e "This build script must be run as sudo."
  exit 100 
fi

# If on Ubuntu 12.04 add Multiverse REPO (not sure if needed, but it can't hurt)
cat /etc/lsb-release | grep 12.04 &> /dev/null
distro=$(echo $?)

if [ $distro -eq 0 ]
then
  cat /etc/apt/sources.list | grep multiverse &> /dev/null
  if [ $? -ne 0 ]
  then
    sudo echo "deb http://archive.ubuntu.com/ubuntu/ precise multiverse" >> /etc/apt/sources.list \
    || echo -e "Ubable To Add Multiverse Repository"
    sudo echo "deb http://archive.ubuntu.com/ubuntu/ precise-updates multiverse" >> /etc/apt/sources.list \
    || echo -e "Ubable To Add Multiverse Repository"
  fi
fi


sudo apt-get update

sudo apt-get -y install autoconf automake build-essential checkinstall pkg-config git mercurial \
  libgpac-dev libopencore-amrnb-dev libopencore-amrwb-dev \
  libtool pkg-config texi2html zlib1g-dev libass-dev libsdl1.2-dev nasm \
  libasound2-plugins pngcrush atool \
  libexif12 libexif-dev bash-completion libpng-dev \

mkdir ~/gif2mp4

cd ~/gif2mp4
wget http://www.tortall.net/projects/yasm/releases/yasm-1.2.0.tar.gz
tar xzvf yasm-1.2.0.tar.gz
cd yasm-1.2.0
./configure --prefix="/usr/local" --enable-shared
make
sudo make install
make distclean

cd ~/gif2mp4
git clone --depth 1 git://git.videolan.org/x264.git
cd x264
./configure --prefix="/usr/local" --enable-shared
make
sudo make install
make distclean

cd ~/gif2mp4
git clone --depth 1 git://git.code.sf.net/p/opencore-amr/fdk-aac
cd fdk-aac
autoreconf -fiv
./configure --prefix="/usr/local" --disable-shared 
make
sudo make install
make distclean

cd ~/gif2mp4
git clone --depth 1 git://git.videolan.org/ffmpeg.git
cd ffmpeg
./configure --prefix="/usr/local" --extra-cflags="-I/usr/local/include" --extra-ldflags="-L/usr/local/lib" --extra-libs="-ldl" --enable-gpl --enable-nonfree --enable-libass --enable-libfdk-aac --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-libx264 --enable-version3
make
sudo make install

make tools/qt-faststart
sudo checkinstall --pkgname=qt-faststart --pkgversion="$(date +%Y%m%d%H%M)-git" --backup=no --deldoc=yes --fstrans=no --default install -Dm755 tools/qt-faststart  /usr/local/bin/qt-faststart
make distclean

hash x264 ffmpeg ffplay ffprobe
sudo ldconfig

cd ~/gif2mp4
sudo wget ftp://ftp.graphicsmagick.org/pub/GraphicsMagick/GraphicsMagick-LATEST.tar.gz
tar xzvf GraphicsMagick-LATEST.tar.gz
cd GraphicsMagick*
./configure --with-modules --with-perl --with-perl-options --without-x --without-expat --with-xml  --with-shared
make
sudo make install

echo install finished.

ffmpeg
gm 


exit