#!/bin/bash

###########################################################
#                                                         #
#    ITO transcoding server build script                  #
#                                                         #
#    All Rights Reserved 2012 - 2014                      #
#    GPL-3 License                                        #
#                                                         #
#    IMAGE:       graphicsmagick lensfun ufraw            #
#                 opencv phantomjs                        #
#    AV:          ffmpeg sox                              #
#    META:        exiftool libexif                        #
#    DOCS:        unoconv libreoffice                     #
#    ARCHIVES:    atool lesspipe                          #
#    3D:          stl2pov meshconv meshlab 3JS            #
#    STACK:       nodejs RIAK mongoDB bash                #
#    IRON:        Ubuntu 12.04 Server Xvfb                #
#    ANTIVIRUS:   clamav                                  #
#                                                         #
#    Featuring: VP9, WEBP, H265, FDK-AAC, STL / OBJ       #
#                                                         #
#                                                         #
###########################################################

#TODO: Run Test at the End and according to the results set the available mimes

# throw a pretty error and stop
BuildError()
{
    COMMENT=$1
    COMMAND=$2
    COLUMNS=$(tput cols)
    SCRIPT=$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")
    SCRIPTDIR=$(dirname ${SCRIPT})
    TITLE="${PACKAGE} ERROR"
    echo -e "\e[1;37;41m"
    printf "%*s\n" $(($COLUMNS)) "ERROR                     "
    echo -e "\e[0m\e[31m"
    #printf "%*s\n" $(((${#TITLE}+$COLUMNS)/2)) "${TITLE}"
	echo -e "\e[36m   PACKAGE:        ${PACKAGE}"
	echo -e "   ERROR:          ${1}"
    echo -e "   DIRECTORY:      ${PWD}"
    echo -e "   SCRIPT:         ${0}" #${SCRIPTDIR}/${SCRIPT}
	echo -e "   BREAK POINT:    Line ${BASH_LINENO[$i]}"
    echo -e "\e[1;31;41m"
    printf "%*s\n" $((${COLUMNS})) ""
    echo -e "\e[0m"
	exit 101
}

BuildMessage()
{
    clear
	echo -e "\e[1;42;36m $@ \e[0m"
}

PACKAGE=$(grep 'PACKAGE'  '../version.json' | cut -d'"' -f4)
VERSION=$(grep 'VERSION'  '../version.json' | cut -d'"' -f4)
DESCRIPTION=$(grep 'DESCRIPTION'  '../version.json' | cut -d'"' -f4)
CONTACT=$(grep 'CONTACT' '../version.json' | cut -d'"' -f4)

INSTALLROOT="~/${PACKAGE}_sources"

# Checking Permissions
Permission=$(id -u)
PACKAGE="Permissions"
# Exit if not being run as Sudo
if [ $Permission -ne 0 ] 
then
  BuildError "This build script must be run as sudo."
fi

# todo: why only ubuntu 12.04? May 14.04 work as well?
# todo: test on a vm

# Exit if not being run on Ubuntu 12.04
cat /etc/lsb-release | grep 12.04 &> /dev/null
distro=$(echo $?)

if [ $distro -ne 0 ]
then
  BuildError "This build script must be run on Ubuntu 12.04."  
fi

# Exit if not being run on Ubuntu Server
dpkg --list | grep ubuntu-desktop &> /dev/null
notServer=$(echo $?)

if [ $notServer -ne 0 ]
then
  BuildError "This build script must be run on Ubuntu Server"  
fi


PACKAGE="Sources"
cat /etc/apt/sources.list | grep multiverse &> /dev/null
if [ $? -ne 0 ]
then
  sudo echo "deb http://archive.ubuntu.com/ubuntu/ precise multiverse" >> /etc/apt/sources.list \
  || BuildError "Ubable To Add Multiverse Repository"
  sudo echo "deb http://archive.ubuntu.com/ubuntu/ precise-updates multiverse" >> /etc/apt/sources.list \
  || BuildError "Ubable To Add Multiverse Repository"
fi

# In case this is being run as an update, we need to get rid of these...
# I'm a package manager, whee!

if test $1 -eq "-update"
then
    #TODO: get list of all locals created here and add them to the list below
    #TODO: on UPDATE lock the queue of transcoding
    sudo rm -rf ${INSTALLROOT} /usr/local/bin/{ffmpeg,ffprobe,ffserver,vsyasm,x264,yasm,ytasm}
fi

BuildMessage "Installing Dependencies with apt-get."
sudo apt-get install -y deb-multimedia-keyring || BuildError "deb-multimedia-keyring could not be installed"

sudo add-apt-repository -y ppa:crass/ufraw || BuildError "Ufraw Repository Could not be added"

PACKAGE="apt-get"

sudo apt-get update || BuildError "Dependencies Update Failed"
sudo apt-get -y upgrade || BuildError "System Upgrade Failed"

clear
BuildMessage "Installing system dependencies"

sudo apt-get -y install autoconf automake build-essential checkinstall pkg-config git mercurial \
  chrpath git-core libperl-dev libperl5.14 bash-completion libssl-dev xdg-utils libtool detox \
    || BuildError "Could not install system dependencies"

BuildMessage "Installing ffmpeg / AV dependencies"
sudo apt-get -y install libfaac-dev \
  libgpac-dev libjack-jackd2-dev libmp3lame-dev libopencore-amrnb-dev libopencore-amrwb-dev \
  librtmp-dev libtheora-dev libvorbis-dev libflac-dev flac \
  texi2html zlib1g-dev libass-dev libsdl1.2-dev frei0r-plugins-dev nasm \
  libasound2-plugins libasound2-python libsox1b libsox-fmt-all libsox-fmt-ffmpeg sox libxvidcore-dev \
  atool mplayer gstreamer \
  mediainfo \
    || BuildError "Could not install ffmpeg / AV dependencies"

BuildMessage "Installing image & openCV dependencies"
sudo apt-get -y install \
  icc-profiles \
  libexif12 libexif-dev libimage-exiftool-perl \
  libtiff-dev libtiff5 libtiff5-dev libtiff-tools \
  libjpeg-dev libjpeg8 libjpeg8-dbg libjpeg62 libjpeg62-dev libjpeg-progs \
  libpng-dev libgif-dev pngcrush libpng12-0 libpng12-dev libpng++-dev libpng3 libpnglite-dev pngtools \
  liblcms1-dev  libexiv2-dev zlib1g-dev libbz2-dev netpbm \
  liblensfun-dev ufraw dcraw \
  zlib1g-dbg zlib1g zlib1g-dev \
  libavcodec-dev libavformat-dev libswscale-dev openexr libopenexr6 libopenexr-dev \
  qrencode opencv \
    || BuildError "Could not install image & openCV dependencies"

BuildMessage "Installing compressed collection dependencies"
sudo apt-get -y install \
  p7zip rar unrar lzip bzip2 file unzip zip \
    || BuildError "Could not install compressed collection dependencies"

BuildMessage "Installing document dependencies"
sudo apt-get -y install \
  ghostscript  python-cairo python-gi-cairo pdftohtml  poppler-utils pdf2svg libfontconfig1-dev \
  libreoffice asciidoc \
    || BuildError "Could not install document dependencies"

BuildMessage "Installing 3D dependencies"
sudo apt-get -y install \
 meshlab xvfb \
    || BuildError "Could not install 3D dependencies"

clear

mkdir ${INSTALLROOT}

PACKAGE="jsawk"
BuildMessage "Building ${PACKAGE}"
cd ${INSTALLROOT}
mkdir jsawk
cd jsawk
curl -L http://github.com/micha/jsawk/raw/master/jsawk > jsawk
chmod 755 jsawk && ln jsawk /usr/local/bin/jsawk


PACKAGE="CMake"
BuildMessage "Building ${PACKAGE}"
cd ${INSTALLROOT}
git clone https://github.com/Kitware/CMake.git || BuildError "Could not be downloaded:"
cd CMake
sudo ./bootstrap || BuildError "Could not ./bootstrap"
sudo make || BuildError "Could not make"
sudo make install || BuildError "Could not make install"
make distclean

PACKAGE="yasm"
BuildMessage "Building ${PACKAGE}"
cd ${INSTALLROOT}
wget http://www.tortall.net/projects/yasm/releases/yasm-1.2.0.tar.gz || BuildError "Could not be downloaded"
tar xzvf yasm-1.2.0.tar.gz
cd yasm-1.2.0
./configure --prefix="/usr/local" --enable-shared || BuildError "Could not ./configure"
make || BuildError "Could not make"
sudo checkinstall --pkgname=yasm --pkgversion="1.2.0" --backup=no --deldoc=yes --default \
    || BuildError "Could not checkinstall"
make distclean

PACKAGE="unoconv"
BuildMessage "Building ${PACKAGE}"
cd ${INSTALLROOT}
git clone https://github.com/dagwieers/unoconv || BuildError "Could not be downloaded"
make || BuildError "Could not make"
sudo make install  || BuildError "Could not make install"
make distclean

PACKAGE="ufraw"
BuildMessage "Building ${PACKAGE}"
cd ${INSTALLROOT}
wget http://downloads.sourceforge.net/project/ufraw/ufraw/ufraw-0.21/ufraw-0.21.tar.gz || BuildError "Could not be downloaded"
tar xzf ufraw-0.21.tar.gz
cd ufraw-0.21
./configure --enable-extras --enable-x-trans || BuildError "Could not ./configure"
make || BuildError "Could not make"
sudo make install || BuildError "Could not make install"
make distclean

PACKAGE="x264"
BuildMessage "Building ${PACKAGE}"
cd ${INSTALLROOT}
git clone --depth 1 git://git.videolan.org/x264.git || BuildError "Could not be downloaded"
cd x264
./configure --prefix="/usr/local" --enable-shared || BuildError "Could not ./configure"
make || BuildError "Could not make"
sudo checkinstall --pkgname=x264 --pkgversion="3:$(./version.sh | \
awk -F'[" ]' '/POINT/{print $4"+git"$5}')" --backup=no --deldoc=yes \
--fstrans=no --default \
    || BuildError "Could not checkinstall"
make distclean

PACKAGE="x265"
BuildMessage "Building ${PACKAGE}"
cd ${INSTALLROOT}
hg clone http://hg.videolan.org/x265 || BuildError "Could not be downloaded"
cd x265/build/linux 
sudo ./make-Makefiles.bash || BuildError "Could not ./make-Makefiles.bash"
make || BuildError "Could not make"
sudo checkinstall --pkgname=x265 --backup=no --deldoc=yes \
--fstrans=no --default \
    || BuildError "Could not checkinstall"
make distclean

PACKAGE="fdk-aac"
BuildMessage "Building ${PACKAGE}"
cd ${INSTALLROOT}
git clone --depth 1 git://git.code.sf.net/p/opencore-amr/fdk-aac || BuildError "Could not be downloaded"
cd fdk-aac
autoreconf -fiv || BuildError "Could not autoreconf"
./configure --prefix="/usr/local" --disable-shared  || BuildError "Could not ./configure"
make || BuildError "Could not make"
sudo checkinstall --pkgname=fdk-aac --pkgversion="$(date +%Y%m%d%H%M)-git" --backup=no \
--deldoc=yes --fstrans=no --default \
    || BuildError "Could not checkinstall"
make distclean

PACKAGE="lame"
BuildMessage "Building ${PACKAGE}"
cd ${INSTALLROOT}
wget http://downloads.sourceforge.net/project/lame/lame/3.99/lame-3.99.5.tar.gz || BuildError "Could not be downloaded"
tar xzvf lame-3.99.5.tar.gz
cd lame-3.99.5
./configure --prefix="/usr/local" --enable-nasm --enable-shared || BuildError "Could not ./configure"
make || BuildError "Could not make"
sudo make install || BuildError "Could not make install"
make distclean

PACKAGE="opus"
BuildMessage "Building ${PACKAGE}"
cd ${INSTALLROOT}
wget http://downloads.xiph.org/releases/opus/opus-1.0.3.tar.gz || BuildError "Could not be downloaded"
tar xzvf opus-1.0.3.tar.gz
cd opus-1.0.3
./configure --prefix="/usr/local" --enable-shared || BuildError "Could not ./configure"
make || BuildError "Could not make"
sudo make install || BuildError "Could not make install"
make distclean

PACKAGE="libvpx"
BuildMessage "Building ${PACKAGE}"
cd ${INSTALLROOT}
git clone -b experimental http://git.chromium.org/webm/libvpx.git || BuildError "Could not be downloaded"
cd libvpx
./configure --prefix="/usr/local" --disable-examples --enable-vp9 --enable-shared || BuildError "Could not ./configure"
make || BuildError "Could not make"
sudo make install || BuildError "Could not make install"
make clean

PACKAGE="ffmpeg"
BuildMessage "Building ${PACKAGE}"
cd ${INSTALLROOT}
git clone --depth 1 git://git.videolan.org/ffmpeg.git  || BuildError "Could not be downloaded"
cd ffmpeg
#PKG_CONFIG_PATH="/usr/local"
#export PKG_CONFIG_PATH
./configure --prefix="/usr/local" --extra-cflags="-I/usr/local/include" --extra-ldflags="-L/usr/local/lib" --extra-libs="-ldl" --enable-gpl --enable-nonfree --enable-fontconfig --enable-frei0r  --enable-libass --enable-libfdk-aac --enable-libfaac --enable-libmp3lame --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-libopus --enable-libtheora --enable-libvorbis  --enable-libvpx --enable-libxvid --enable-libx264 --enable-libx265 --enable-version3 || BuildError "Could not ./configure"

make || BuildError "Could not make"
sudo checkinstall --pkgname=ffmpeg --pkgversion="5:$(date +%Y%m%d%H%M)-git" --backup=no --deldoc=yes --fstrans=no --default \
    || BuildError "Could not checkinstall"

PACKAGE="ffmpeg qt-faststart"
BuildMessage "Building ${PACKAGE}"
make tools/qt-faststart || BuildError "Could not make"
sudo checkinstall --pkgname=qt-faststart --pkgversion="$(date +%Y%m%d%H%M)-git" --backup=no --deldoc=yes --fstrans=no --default install -Dm755 tools/qt-faststart  /usr/local/bin/qt-faststart  || BuildError "Could not checkinstall"
make distclean

### cd /usr/lib
### sudo ln -sf libx264.so libx264.so.140
# export PATH=$HOME/archivitekt_transcoder/bin:$PATH

hash x264 ffmpeg ffplay ffprobe
sudo ldconfig

PACKAGE="clamav"
BuildMessage "Building ${PACKAGE}"
sudo useradd clamav || echo -e "Could not add new user clamav"
cd ${INSTALLROOT}
wget http://sourceforge.net/projects/clamav/files/latest/download || BuildError "Could not be downloaded"
tar xvzf download
mv download clamav.tar.gz
cd clam*
./configure || BuildError "Could not ./configure"
make || BuildError "Could not make"
sudo make install  || BuildError "Could not make install"

# make the default conf for freshclam
echo "
DatabaseMirror database.clamav.net
DatabaseDirectory /var/clamav/db
UpdateLogFile /var/clamav/log/freshclam.log
" > /usr/local/etc/freshclam.conf  || BuildError "freshclam.conf creation Failed"

sudo mkdir /var/clamav
sudo mkdir /var/clamav/db
sudo mkdir /var/clamav/log 
sudo touch /var/clamav/log/freshclam.log
sudo chmod 0755 /var/clamav -R
sudo chown clamav:100 /var/clamav -R

BuildMessage "Getting clamav descriptions"
# get virus descriptions
sudo freshclam  || BuildError "Could not get virus definitions."

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

PACKAGE="lcms"
BuildMessage "Building ${PACKAGE}"
# lcms is an add-on of graphicsmagick to perform ICC CMS color management.
cd ${INSTALLROOT}
wget http://sourceforge.net/projects/lcms/files/latest/download || BuildError "Could not be downloaded"
mv download lcms.tar.gz
tar xzvf lcms.tar.gz
cd lcms*
./configure  || BuildError "Could not ./configure"
make || BuildError "Could not make"
sudo make install || BuildError "Could not make install"

PACKAGE="zlib"
BuildMessage "Building ${PACKAGE}"
# zlib is another GM dep to handle compressed PNG and MIFF images.
cd ${INSTALLROOT}
wget http://zlib.net/zlib-1.2.8.tar.gz || BuildError "Could not be downloaded"
tar xzvf zlib-1.2.8.tar.gz
cd zlib*
./configure || BuildError "Could not ./configure"
make || BuildError "Could not make"
sudo make install || BuildError "Could not make install"

PACKAGE="libwebp"
BuildMessage "Building ${PACKAGE}"
# can't forget this one, can we.
cd ${INSTALLROOT}
git clone https://chromium.googlesource.com/webm/libwebp || BuildError "Could not be downloaded"
cd libwebp
./autogen.sh  || BuildError "Could not ./autogen.sh"
./configure --enable-everything  || BuildError "Could not ./configure"
make || BuildError "Could not make"
sudo make install || BuildError "Could not make install"

PACKAGE="jasper (jpeg2000)"
BuildMessage "Building ${PACKAGE}"
# jpeg2000 for GM
cd ${INSTALLROOT}
wget http://www.ece.uvic.ca/~frodo/jasper/software/jasper-1.900.1.zip || BuildError "Could not be downloaded"
unzip jasper-1.900.1.zip
cd jasper*

#fix from graphicsmagick -> http://www.graphicsmagick.org/README.html#add-on-libraries-programs
sed -i".bak" '/atexit(jas_cleanup);/d' src/libjasper/base/jas_init.c
mv src/libjasper/base/jas_init.c.bak src/libjasper/base/jas_init.c
./configure || BuildError "Could not ./configure"
make || BuildError "Could not make"
sudo make install || BuildError "Could not make install"

PACKAGE="GraphicsMagick"
BuildMessage "Building ${PACKAGE}"
# GraphicsMagick instead of Imagemagick cuz its faster - except to download... ;)
cd ${INSTALLROOT}
sudo wget ftp://ftp.graphicsmagick.org/pub/GraphicsMagick/GraphicsMagick-LATEST.tar.gz || BuildError "Could not be downloaded"
tar xzvf GraphicsMagick-LATEST.tar.gz
cd GraphicsMagick*
./configure --with-modules --with-perl --with-perl-options --without-x --without-expat --with-xml  --with-shared || BuildError "Could not ./configure"
make || BuildError "Could not make"
sudo make install || BuildError "Could not make install"

# 3D stuff


PACKAGE="three.js"
BuildMessage "Building ${PACKAGE}"
cd ${INSTALLROOT}
git clone https://github.com/mrdoob/three.js.git || BuildError "Could not be downloaded"
cd three.js/utils/converters

# ctm
#    CTM

# fbx
#    Fbx (.fbx)
#    Collada (.dae)
#    Wavefront/Alias (.obj)
#    3D Studio Max (.3ds)

# msgpack
#    convert a json file to msgpack .json > .pack

# obj
# python convert_obj_three.py -i infile.obj -o outfile.js [-m "morphfiles*.obj"] [-c "morphcolors*.obj"] [-a center|centerxz|top|bottom|none] [-s smooth|flat] [-t ascii|binary] [-d invert|normal] [-b] [-e]






PACKAGE="py-stl"
BuildMessage "Building ${PACKAGE}"
# py-stl with a cli make install
cd ${INSTALLROOT}
wget http://rsmith.home.xs4all.nl/files/py-stl-3.1.zip || BuildError "Could not be downloaded"
unzip py-stl-3.1.zip
cd py-stl*
mkdir /usr/local/bin/py-stl
/usr/bin/install -c -m 755 stl2pdf.py '/usr/local/bin/stl2pdf.py' || BuildError "Could not install"
/usr/bin/install -c -m 755 stl2pov.py '/usr/local/bin/stl2pov.py' || BuildError "Could not install"
/usr/bin/install -c -m 755 stl2ps.py '/usr/local/bin/stl2ps.py' || BuildError "Could not install"
/usr/bin/install -c -m 755 setup.py '/usr/local/bin/setup.py' || BuildError "Could not install"
/usr/bin/install -c -m 755 stlinfo.py '/usr/local/bin/stlinfo.py' || BuildError "Could not install"
/usr/bin/install -c -m 755 stl.py '/usr/local/bin/stl.py' || BuildError "Could not install"
/usr/bin/install -c -m 755 xform.py '/usr/local/bin/xform.py' || BuildError "Could not install"

sudo ldconfig


PACKAGE="meshconv"
BuildMessage "Building ${PACKAGE}"
# meshconv binary
# import:PLY, STL, OFF, OBJ, 3DS, COLLADA, PTX, V3D, PTS, APTS, XYZ, GTS, TRI, ASC, X3D, X3DV, VRML, ALN
# export:PLY, STL, OFF, OBJ, 3DS, COLLADA, VRML, DXF, GTS, U3D, IDTF, X3D
cd ${INSTALLROOT}
wget wget http://www.cs.princeton.edu/~min/meshconv/linux64/meshconv || BuildError "Could not be downloaded"
/usr/bin/install -c -m 755 meshconv '/usr/local/bin/meshconv' || BuildError "Could not install"

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

PACKAGE="libpng 1.6"
BuildMessage "Building ${PACKAGE}"
cd ${INSTALLROOT}
wget http://sourceforge.net/projects/libpng/files/libpng16/1.6.17/libpng-1.6.17.tar.gz || BuildError "Could not be downloaded"
tar xzvf libpng-1.6.17.tar.gz
cd libpng-1.6.17
./configure || BuildError "Could not ./configure"
make || BuildError "Could not make"
sudo make install || BuildError "Could not make install"

# modify the makefile ->
# else ifneq "$(wildcard /opt/local/include/libpng16)" ""

PACKAGE="pngquant"
BuildMessage "Building ${PACKAGE}"
cd ${INSTALLROOT}
git clone https://github.com/pornel/pngquant.git || BuildError "Could not be downloaded"
cd pngquant
# switch out libpng15 with libpng16 in the Makefile
sed -i -e 's/libpng15/libpng16/g' Makefile 

make  || BuildError "Could not make"
sudo make install || BuildError "Could not make install"
ln -s /usr/local/bin/pngquant /usr/bin/pngquant
ldconfig

PACKAGE="phantomjs"
BuildMessage "Building ${PACKAGE}"
cd ${INSTALLROOT}
git clone https://github.com/ariya/phantomjs.git || BuildError "Could not be downloaded"
cd phantomjs
git checkout 1.9 || BuildError "Could git checkout"
./build.sh  || BuildError "Could not ./build.sh"
sudo cp bin/phantomjs /usr/local/bin/phantomjs
sudo ldconfig


#wow.
clear
BuildMessage "Seems like everything worked. Here are a few results:"
sleep 1
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