#!/bin/bash

# build script for simulacra


# Checking Permissions
Permission=$(id -u)

# Exit if not being run as Sudo
if [ $Permission -ne 0 ]
then
  echo -e "This build script must be run as sudo."
  exit 100
fi

# Exit if not being run on Ubuntu 14.04
cat /etc/lsb-release | grep 14.04 &> /dev/null
distro=$(echo $?)

if [ ${distro} -ne 0 ]
then
  echo -e "This build script must be run on Ubuntu 12.04."
  exit 100
fi

# Exit if not being run on Ubuntu Server
dpkg --list | grep ubuntu-desktop &> /dev/null
notServer=$(echo ${?})

if [ ${notServer} -ne 0 ]
then
  echo -e "This build script must be run on Ubuntu Server"
  exit 100
fi

# throw an error and stop
BuildError()
{
	echo -e "\e[31m$@ \e[0m"
	exit 101
}


cat /etc/apt/sources.list | grep multiverse &> /dev/null
if [ $? -ne 0 ]
then
  sudo echo "deb http://archive.ubuntu.com/ubuntu/ trusty multiverse" >> /etc/apt/sources.list \
  || BuildError "Ubable To Add Multiverse Repository"
  sudo echo "deb http://archive.ubuntu.com/ubuntu/ trusty-updates multiverse" >> /etc/apt/sources.list \
  || BuildError "Ubable To Add Multiverse Repository"
else
	echo -e "\033[34m Multiverse Repository Already Enabled... \e[0m"
fi

# Install Deb Multimedia Keys
sudo apt-get install -y deb-multimedia-keyring || BuildError "deb-multimedia-keyring could not be installed"

sudo add-apt-repository -y ppa:crass/ufraw || BuildError "Ufraw Repository Could not be added"


# Update The Dependencies
clear
echo -e "\033[34m Updating Dependencies... \e[0m"
sudo apt-get update || BuildError "Dependencies Update Failed"

sudo apt-get -y upgrade || BuildError "System Upgrade Failed"

#Install The Packages
clear
echo -e "\033[34m  Installing Packages For Ubuntu \e[0m"

sudo apt-get -y install autoconf automake build-essential checkinstall pkg-config git mercurial   libfaac-dev \
  libgpac-dev libjack-jackd2-dev libmp3lame-dev libopencore-amrnb-dev libopencore-amrwb-dev \
  librtmp-dev libtheora-dev libtool libvorbis-dev \
  pkg-config texi2html zlib1g-dev libass-dev libsdl1.2-dev frei0r-plugins-dev nasm \
  libasound2-plugins libasound2-python libsox1b libsox-fmt-all libsox-fmt-ffmpeg sox libxvidcore-dev \
  pngcrush libimage-exiftool-perl atool \
  libexif12 libexif-dev libtiff4 libtiff4-dev ghostscript bash-completion \
  p7zip rar unrar lzip bzip2 file unzip zip \
  libjpeg-dev libpng-dev libtiff-dev libgif-dev libperl-dev libperl5.14 \
  libflac-dev flac python-cairo python-gi-cairo meshlab xvfb \
  qrencode pdftohtml dcraw ghostscript netpbm mplayer poppler-utils pdf2svg libreoffice asciidoc \
  xdg-utils liblcms1-dev icc-profiles libexiv2-dev zlib1g-dev libbz2-dev liblensfun-dev ufraw \
  chrpath git-core libssl-dev libfontconfig1-dev gstreamer || BuildError "Could not install Archive dependencies"

mkdir ~/simulacra_build

cd ~/simulacra_build
git clone https://github.com/Kitware/CMake.git
cd CMake
sudo ./bootstrap 
sudo make 
sudo make install || BuildError "CMake Build Failed"

cd ~/simulacra_build
wget http://www.tortall.net/projects/yasm/releases/yasm-1.2.0.tar.gz
tar xzvf yasm-1.2.0.tar.gz
cd yasm-1.2.0
./configure --prefix="/usr/local" --enable-shared
make
sudo make install || BuildError "yasm Build Failed"
make distclean

cd ~/simulacra_build
git clone https://github.com/dagwieers/unoconv
make
sudo make install || BuildError "unoconv Build Failed"

cd ~/simulacra_build
wget http://downloads.sourceforge.net/project/ufraw/ufraw/ufraw-0.19.2/ufraw-0.19.2.tar.gz
tar xzf ufraw-0.19.2.tar.gz
cd ufraw-0.19.2
./configure --enable-extras --enable-x-trans
make
sudo make install || BuildError "ufraw Build Failed"

cd ~/simulacra_build
git clone --depth 1 git://git.videolan.org/x264.git
cd x264
./configure --prefix="/usr/local" --enable-shared
make
sudo make install || BuildError "x264 Build Failed"
make distclean

cd ~/simulacra_build
hg clone http://hg.videolan.org/x265
cd x265/build/linux 
sudo ./make-Makefiles.bash
make
sudo make install || BuildError "x265 Build Failed"


cd ~/simulacra_build
git clone --depth 1 git://git.code.sf.net/p/opencore-amr/fdk-aac
cd fdk-aac
autoreconf -fiv
./configure --prefix="/usr/local" --disable-shared 
make
sudo make install || BuildError "fdk-aac Build Failed"
make distclean

cd ~/simulacra_build
wget http://downloads.sourceforge.net/project/lame/lame/3.99/lame-3.99.5.tar.gz
tar xzvf lame-3.99.5.tar.gz
cd lame-3.99.5
./configure --prefix="/usr/local" --enable-nasm --enable-shared
make
sudo make install || BuildError "lame Build Failed"
make distclean

cd ~/simulacra_build
wget http://downloads.xiph.org/releases/opus/opus-1.0.3.tar.gz
tar xzvf opus-1.0.3.tar.gz
cd opus-1.0.3
./configure --prefix="/usr/local" --enable-shared
make
sudo make install || BuildError "opus Build Failed"
make distclean

cd ~/simulacra_build
git clone -b experimental http://git.chromium.org/webm/libvpx.git
cd libvpx
./configure --prefix="/usr/local" --disable-examples --enable-vp9 --enable-shared
make
sudo make install || BuildError "libvpx Build Failed"
make clean


cd ~/simulacra_build
git clone --depth 1 git://git.videolan.org/ffmpeg.git
cd ffmpeg
#PKG_CONFIG_PATH="/usr/local"
#export PKG_CONFIG_PATH
./configure --prefix="/usr/local" --extra-cflags="-I/usr/local/include" --extra-ldflags="-L/usr/local/lib" --extra-libs="-ldl" --enable-gpl --enable-nonfree --enable-fontconfig --enable-frei0r  --enable-libass --enable-libfdk-aac --enable-libfaac --enable-libmp3lame --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-libopus --enable-libtheora --enable-libvorbis  --enable-libvpx --enable-libxvid --enable-libx264 --enable-libx265 --enable-version3

make
sudo make install || BuildError "ffmpeg Build Failed"


make tools/qt-faststart
sudo checkinstall --pkgname=qt-faststart --pkgversion="$(date +%Y%m%d%H%M)-git" --backup=no --deldoc=yes --fstrans=no --default install -Dm755 tools/qt-faststart  /usr/local/bin/qt-faststart || BuildError "qt-faststart Build Failed"

make distclean

### cd /usr/lib
### sudo ln -sf libx264.so libx264.so.140
# export PATH=$HOME/simulacra_build/bin:$PATH

hash x264 ffmpeg ffplay ffprobe
sudo ldconfig

sudo useradd clamav
cd ~/simulacra_build
wget http://sourceforge.net/projects/clamav/files/latest/download
tar xvzf download
cd clam*
./configure
make 
sudo make install || BuildError "clamav Build Failed"

# make the default conf for freshclam
echo "
DatabaseMirror database.clamav.net
DatabaseDirectory /var/clamav/db
UpdateLogFile /var/clamav/log/freshclam.log
" > /usr/local/etc/freshclam.conf

sudo mkdir /var/clamav
sudo mkdir /var/clamav/db
sudo mkdir /var/clamav/log 
sudo touch /var/clamav/log/freshclam.log
sudo chmod 0755 /var/clamav -R
sudo chown clamav:100 /var/clamav -R

# get virus descriptions
sudo freshclam || BuildError "freshclam virus signature pull failed"




# lcms is an add-on of graphicsmagick to perform ICC CMS color management.
cd ~/simulacra_build
wget http://sourceforge.net/projects/lcms/files/latest/download
tar xzvf download
cd lcms*
./configure
make
sudo make install || BuildError "lcms Build Failed"

# zlib is another GM dep to handle compressed PNG and MIFF images.
cd ~/simulacra_build
wget http://zlib.net/zlib-1.2.8.tar.gz
tar xzvf zlib-1.2.8.tar.gz
cd zlib*
./configure
make
sudo make install || BuildError "zlib Build Failed"

# can't forget this one, can we.
cd ~/simulacra_build
git clone https://chromium.googlesource.com/webm/libwebp
cd libwebp
./autogen.sh 
./configure --enable-everything
make
sudo make install || BuildError "libwebp Build Failed"

# jpeg2000 for GM
cd ~/simulacra_build
wget http://www.ece.uvic.ca/~frodo/jasper/software/jasper-1.900.1.zip
unzip jasper-1.900.1.zip
cd jasper*

#fix from graphicsmagick -> http://www.graphicsmagick.org/README.html#add-on-libraries-programs
sed -i".bak" '/atexit(jas_cleanup);/d' src/libjasper/base/jas_init.c
mv src/libjasper/base/jas_init.c.bak src/libjasper/base/jas_init.c
./configure
make
sudo make install || BuildError "jasper Build Failed"

# GraphicsMagick instead of Imagemagick cuz its faster - except to download... ;)
cd ~/simulacra_build
sudo wget ftp://ftp.graphicsmagick.org/pub/GraphicsMagick/GraphicsMagick-LATEST.tar.gz
tar xzvf GraphicsMagick-LATEST.tar.gz
cd GraphicsMagick*
./configure --with-modules --with-perl --with-perl-options --without-x --without-expat --with-xml  --with-shared
make
sudo make install || BuildError "GM Build Failed"

cd ~/simulacra_build
git clone https://github.com/pornel/pngquant.git
cd pngquant
# switch out libpng15 with libpng16 in the Makefile
sed -i -e 's/libpng15/libpng16/g' Makefile 

make
sudo make install || BuildError "pngquant Build Failed"
ln -s /usr/local/bin/pngquant /usr/bin/pngquant
ldconfig

cd ~/simulacra_build
git clone https://github.com/ariya/phantomjs.git
cd phantomjs
git checkout 1.9
./build.sh || BuildError "phantomjs Build Failed"
sudo cp bin/phantomjs /usr/local/bin/phantomjs
sudo ldconfig


##########
# Now we'll add OpenCV to the mix
##########

# libcv deps
sudo apt-get install libgtk2.0-dev python-dev python-numpy -y || BuildError "Could not install LibCV Dependencies"

# libcv imagedeps
sudo apt-get install libpng12-0 libpng12-dev libpng++-dev libpng3 libpnglite-dev zlib1g-dbg zlib1g zlib1g-dev pngtools libjpeg-dev libjpeg8 libjpeg8-dbg libjpeg62 libjpeg62-dev libjpeg-progs libtiff5 libtiff5-dev libtiff-tools libavcodec-dev libavformat-dev libswscale-dev openexr libopenexr6 libopenexr-dev -y || BuildError "Could not install LibCV Image Deps"

cd ~/simulacra_build
git clone https://github.com/Itseez/opencv.git
cd opencv
mkdir release
cd release

cmake -D OPENCV_EXTRA_MODULES_PATH=/modules -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local -D WITH_V4L=ON -D WITH_GSTREAMER=ON -D WITH_OPENEXR=ON -D WITH_UNICAP=ON -D BUILD_PYTHON_SUPPORT=ON -D INSTALL_C_EXAMPLES=ON -D INSTALL_PYTHON_EXAMPLES=ON -D BUILD_EXAMPLES=ON ..

http://github.com/Itseez/opencv_extra.git
http://github.com/Itseez/opencv_contrib.git
cmake OPENCV_EXTRA_MODULES_PATH=/modules
# here is a static version
# https://github.com/Itseez/opencv/archive/3.0.0-alpha.zip

#### THIS IS EXTREMELY TRICKY AND SHOULD PROBABLY BE DONE BY HAND