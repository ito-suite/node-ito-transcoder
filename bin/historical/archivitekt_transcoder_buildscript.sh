#!/bin/bash

###########################################################
#       _             _     _       _ _       _    _      #
#      / \   _ __ ___| |__ (_)_   _(_) |_ ___| | _| |_    #
#     / △ \ | '__/ __| '_ \| \ \ / / | __/ _ \ |/ / __|   #
#    / ___ \| | | (__| | | | |\ V /| | ||  __/   <| |_    #
#   /_/   \_\_|  \___|_| |_|_| \_/ |_|\__\___|_|\_\__|    #
#   ===================================================   #
#   Archive Construction for Modern Media Professionals   #
#                                                         #
###########################################################

###########################################################
#                                                         #
#    anymedia transcoding server build script  !          #
#                                                         #
#    All Rights Reserved 2012 - 2014                      #
#    Not for distribution.                                #
#                                                         #
#    this package: v 0.1 > FishChowder                    #
#                                                         #
#    IMAGE:       graphicsmagick lensfun ufraw            #
#                                                         #
#    AV:          ffmpeg sox clamav                       #
#    META:        exiftool libexif                        #
#    DOCS:        unoconv libreoffice                     #
#    ARCHIVES:    atool lesspipe                          #
#    3D:          stl2pov meshconv meshlab                #
#    STACK:       nodejs RIAK mongoDB bash                #
#    IRON:        Ubuntu 12.04 Server Xvfb                #
#    STANDARDS:   DCMI RDF,                               #
#                 IETF RFC 5013                           #
#                 ISO Standard 15836-2009                 #
#                 NISO Standard Z39.85                    #
#                                                         #
#    Featuring: VP9, WEBP, H265, FDK-AAC, STL / OBJ       #
#                                                         #
###########################################################


# Checking Permissions
Permission=$(id -u)

# Exit if not being run as Sudo
if [ $Permission -ne 0 ] 
then
  echo -e "This build script must be run as sudo."
  exit 100 
fi

# Exit if not being run on Ubuntu 12.04
cat /etc/lsb-release | grep 12.04 &> /dev/null
distro=$(echo $?)

if [ $distro -ne 0 ]
then
  echo -e "This build script must be run on Ubuntu 12.04."  
  exit 100
fi

# Exit if not being run on Ubuntu Server
dpkg --list | grep ubuntu-desktop &> /dev/null
notServer=$(echo $?)

if [ $notServer -ne 0]
then
  echo -e "This build script must be run on Ubuntu Server"  
  exit 100
fi

# throw an error and stop
error()
{
  echo -e "$@"
  exit 100
}


cat /etc/apt/sources.list | grep multiverse &> /dev/null
if [ $? -ne 0 ]
then
  sudo echo "deb http://archive.ubuntu.com/ubuntu/ precise multiverse" >> /etc/apt/sources.list \
  || echo -e "Ubable To Add Multiverse Repository"
  sudo echo "deb http://archive.ubuntu.com/ubuntu/ precise-updates multiverse" >> /etc/apt/sources.list \
  || echo -e "Ubable To Add Multiverse Repository"
fi

# In case this is being run as an update, we need to get rid of these...
# I'm a package manager, whee!
#rm -rf ~/archivitekt_transcoder /usr/local/bin/{ffmpeg,ffprobe,ffserver,vsyasm,x264,yasm,ytasm}

sudo apt-get update
sudo apt-get -y upgrade

sudo add-apt-repository -y ppa:crass/ufraw

sudo apt-get -y install autoconf automake build-essential checkinstall pkg-config git mercurial \
  libfaac-dev \
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
  chrpath git-core libssl-dev libfontconfig1-dev gstreamer



mkdir ~/archivitekt_transcoder


cd ~/archivitekt_transcoder
git clone https://github.com/Kitware/CMake.git
cd CMake
sudo ./bootstrap 
sudo make 
sudo make install

cd ~/archivitekt_transcoder
wget http://www.tortall.net/projects/yasm/releases/yasm-1.2.0.tar.gz
tar xzvf yasm-1.2.0.tar.gz
cd yasm-1.2.0
./configure --prefix="/usr/local" --enable-shared
make
sudo make install
make distclean

cd ~/archivitekt_transcoder
git clone https://github.com/dagwieers/unoconv
make
sudo make install

cd ~/archivitekt_transcoder
wget http://downloads.sourceforge.net/project/ufraw/ufraw/ufraw-0.19.2/ufraw-0.19.2.tar.gz
tar xzf ufraw-0.19.2.tar.gz
cd ufraw-0.19.2
./configure --enable-extras --enable-x-trans
make
sudo make install

cd ~/archivitekt_transcoder
git clone --depth 1 git://git.videolan.org/x264.git
cd x264
./configure --prefix="/usr/local" --enable-shared
make
sudo make install
make distclean

cd ~/archivitekt_transcoder
hg clone http://hg.videolan.org/x265
cd x265/build/linux 
sudo ./make-Makefiles.bash
make
sudo make install


cd ~/archivitekt_transcoder
git clone --depth 1 git://git.code.sf.net/p/opencore-amr/fdk-aac
cd fdk-aac
autoreconf -fiv
./configure --prefix="/usr/local" --disable-shared 
make
sudo make install
make distclean

cd ~/archivitekt_transcoder
wget http://downloads.sourceforge.net/project/lame/lame/3.99/lame-3.99.5.tar.gz
tar xzvf lame-3.99.5.tar.gz
cd lame-3.99.5
./configure --prefix="/usr/local" --enable-nasm --enable-shared
make
sudo make install
make distclean

cd ~/archivitekt_transcoder
wget http://downloads.xiph.org/releases/opus/opus-1.0.3.tar.gz
tar xzvf opus-1.0.3.tar.gz
cd opus-1.0.3
./configure --prefix="/usr/local" --enable-shared
make
sudo make install
make distclean

cd ~/archivitekt_transcoder
git clone -b experimental http://git.chromium.org/webm/libvpx.git
cd libvpx
./configure --prefix="/usr/local" --disable-examples --enable-vp9 --enable-shared
make
sudo make install
make clean


cd ~/archivitekt_transcoder
git clone --depth 1 git://git.videolan.org/ffmpeg.git
cd ffmpeg
#PKG_CONFIG_PATH="/usr/local"
#export PKG_CONFIG_PATH
./configure --prefix="/usr/local" --extra-cflags="-I/usr/local/include" --extra-ldflags="-L/usr/local/lib" --extra-libs="-ldl" --enable-gpl --enable-nonfree --enable-fontconfig --enable-frei0r  --enable-libass --enable-libfdk-aac --enable-libfaac --enable-libmp3lame --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-libopus --enable-libtheora --enable-libvorbis  --enable-libvpx --enable-libxvid --enable-libx264 --enable-libx265 --enable-version3

make
sudo make install


make tools/qt-faststart
sudo checkinstall --pkgname=qt-faststart --pkgversion="$(date +%Y%m%d%H%M)-git" --backup=no --deldoc=yes --fstrans=no --default install -Dm755 tools/qt-faststart  /usr/local/bin/qt-faststart

make distclean

### cd /usr/lib
### sudo ln -sf libx264.so libx264.so.140
# export PATH=$HOME/archivitekt_transcoder/bin:$PATH

hash x264 ffmpeg ffplay ffprobe
sudo ldconfig

sudo useradd clamav
cd ~/archivitekt_transcoder
wget http://sourceforge.net/projects/clamav/files/latest/download
tar xvzf download
cd clam*
./configure
make 
sudo make install

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
sudo freshclam

# now it is time to make fishchowder. you will have the time to prepare it
# before freshclam is finished, and by the time the rest is done you will be 
# able to sit down at dinner.
#
# you will need: 
# 2 kg fish
# 1 kg potatoes, peeled and quarted
# 4 large onions, peeled and chopped (not diced)
# 2 liters of fish stock (or 1 Tbsp sardine sauce in 2 L water)
# 5 bay leaves 
# 1 liter of milk

# 1/2 liter heavy cream
# 2 tbsp butter
# 2 tbsp salt
# 2 tsp fresh ground black pepper
#
# Brown the onions in the butter in a large pot. Add the fish stock and bring
# to a boil. Once boiling, add the fish, potatoes and bay leaves. Reduce the heat to medium. 
# After 10 minutes reduce the heat to simmer, add cream, milk, salt and pepper. Let simmer for 45 minutes.
# Serve steaming hot with croutons.



# lcms is an add-on of graphicsmagick to perform ICC CMS color management.
cd ~/archivitekt_transcoder
wget http://sourceforge.net/projects/lcms/files/latest/download
tar xzvf download
cd lcms*
./configure
make
sudo make install

# zlib is another GM dep to handle compressed PNG and MIFF images.
cd ~/archivitekt_transcoder
wget http://zlib.net/zlib-1.2.8.tar.gz
tar xzvf zlib-1.2.8.tar.gz
cd zlib*
./configure
make
sudo make install

# can't forget this one, can we.
cd ~/archivitekt_transcoder
git clone https://chromium.googlesource.com/webm/libwebp
cd libwebp
./autogen.sh 
./configure --enable-everything
make
sudo make install

# jpeg2000 for GM
cd ~/archivitekt_transcoder
wget http://www.ece.uvic.ca/~frodo/jasper/software/jasper-1.900.1.zip
unzip jasper-1.900.1.zip
cd jasper*

#fix from graphicsmagick -> http://www.graphicsmagick.org/README.html#add-on-libraries-programs
sed -i".bak" '/atexit(jas_cleanup);/d' src/libjasper/base/jas_init.c
mv src/libjasper/base/jas_init.c.bak src/libjasper/base/jas_init.c
./configure
make
sudo make install

# GraphicsMagick instead of Imagemagick cuz its faster - except to download... ;)
cd ~/archivitekt_transcoder
sudo wget ftp://ftp.graphicsmagick.org/pub/GraphicsMagick/GraphicsMagick-LATEST.tar.gz
tar xzvf GraphicsMagick-LATEST.tar.gz
cd GraphicsMagick*
./configure --with-modules --with-perl --with-perl-options --without-x --without-expat --with-xml  --with-shared
make
sudo make install

# py-stl with a cli make install
cd ~/archivitekt_transcoder
wget http://rsmith.home.xs4all.nl/files/py-stl-3.1.zip
unzip py-stl-3.1.zip
cd py-stl*
mkdir /usr/local/bin/py-stl
/usr/bin/install -c -m 755 stl2pdf.py '/usr/local/bin/stl2pdf.py'
/usr/bin/install -c -m 755 stl2pov.py '/usr/local/bin/stl2pov.py'
/usr/bin/install -c -m 755 stl2ps.py '/usr/local/bin/stl2ps.py'
/usr/bin/install -c -m 755 setup.py '/usr/local/bin/setup.py'
/usr/bin/install -c -m 755 stlinfo.py '/usr/local/bin/stlinfo.py'
/usr/bin/install -c -m 755 stl.py '/usr/local/bin/stl.py'
/usr/bin/install -c -m 755 xform.py '/usr/local/bin/xform.py'


# meshconv binary
# import:PLY, STL, OFF, OBJ, 3DS, COLLADA, PTX, V3D, PTS, APTS, XYZ, GTS, TRI, ASC, X3D, X3DV, VRML, ALN
# export:PLY, STL, OFF, OBJ, 3DS, COLLADA, VRML, DXF, GTS, U3D, IDTF, X3D
cd ~/archivitekt_transcoder
wget wget http://www.cs.princeton.edu/~min/meshconv/linux64/meshconv
/usr/bin/install -c -m 755 meshconv '/usr/local/bin/meshconv'

sudo ldconfig

echo '
#! /bin/sh

### BEGIN INIT INFO
# Provides: Xvfb
# Required-Start: $local_fs $remote_fs
# Required-Stop:
# X-Start-Before:
# Default-Start: 2 3 4 5
# Default-Stop:
### END INIT INFO

N=/etc/init.d/Xvfb

set -e

case "$1" in
  start)
Xvfb :99 -screen 0 1024x768x24 &
;;
  stop|reload|restart|force-reload)
;;
  *)  
echo "Usage: $N {start|stop|restart|force-reload}" >&2exit 1
;;
esac
' > /etc/init.d/Xvfb
update-rc.d Xvfb defaults

cd ~/archivitekt_transcoder
wget http://sourceforge.net/projects/libpng/files/libpng16/1.6.10/libpng-1.6.10.tar.gz
tar xzvf libpng-1.6.10.tar.gz
cd libpng-1.6.10
./configure
make 
sudo make install

# modify the makefile ->
# else ifneq "$(wildcard /opt/local/include/libpng16)" ""

cd ~/archivitekt_transcoder
git clone https://github.com/pornel/pngquant.git
cd pngquant
# switch out libpng15 with libpng16 in the Makefile
sed -i -e 's/libpng15/libpng16/g' Makefile 

make
sudo make install
ln -s /usr/local/bin/pngquant /usr/bin/pngquant
ldconfig

cd ~/archivitekt_transcoder
git clone https://github.com/ariya/phantomjs.git
cd phantomjs
git checkout 1.9
./build.sh
sudo cp bin/phantomjs /usr/local/bin/phantomjs
sudo ldconfig


cd ~/archivitekt_transcoder

#wow.
clear
echo "Seems like everything worked. Here are a few results:"
sleep 5
phantomjs --version
ffmpeg
pngcrush
unoconv --version
exiftool
gm version
meshconv
stl2ps.py
Xvfb & disown
DISPLAY=:0 meshlabserver

exit