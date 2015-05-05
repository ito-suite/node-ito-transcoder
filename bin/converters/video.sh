#!/bin/bash

###########################################################
#                                                         #
#     VIDEOS - Works, but is graveyard slow               #
#                                                         #
###########################################################


huge_width=1920
big_width=1280
med_width=640
sml_width=320
tiny_width=160
thumb_width=120

# . ./presets.sh

touch ${PROGRESSFILE}

#get our info
ffprobe -show_streams "${ACTIVEFILE}" 2>/dev/null > ${PROGRESSFILE}

# its_offset is used to sync up the audio and video.
# we'll reuse the PROGRESSFILE during transcoding
ITSOFFSET=$(grep "start_time=" "${PROGRESSFILE}" | cut -d= -f2)
if [[ ${ITSOFFSET} > "0.000000" ]]; then
    offset="-its_offset ${ITSOFFSET}"
fi

#we also need to check if interlaced
interlaced=$(ffmpeg -filter:v idet -frames:v 100 -an -f rawvideo -y /dev/null -i "${ACTIVEFILE}" 2>&1 | egrep 'idet|Input' | cut -d':' -f5 | cut -d' ' -f1)
interlace=$(echo ${interlaced} | cut -d' ' -f2)
if [[ $interlace > 0 ]]; then
    echo "is probably interleaved. do something about this."
fi


echo $(echo ${interlaced} | cut -d' ' -f2)
echo ITS $(echo ${ITSOFFSET} | cut -d' ' -f1) # might be wrong depending on which is the video stream. :(

# as well as fix up the SAR DAR shitty shit
#  -vf setdar=dar=0,setsar=sar=0 -x264opts colorprim=bt709:transfer=bt709:colormatrix=bt709:fullrange=off
#-vf "scale=1024:576,setdar=16:9" -aspect 16:9

# pix sar dar should give x/y |SAR 1:1  DAR 16:9] =1.77777778
# we have  720/576 [SAR 64:45 DAR 16:9] =1.25
# take the lowest value (576) >

# we put the temp in the local folder to minimize bleed into other processes

# calculate the aspect ratio
# we are reusing the progressfile
d_aspect_ratio=$(grep "display_aspect_ratio=" "${PROGRESSFILE}" | cut -d'=' -f2)
s_aspect_ratio=$(grep "sample_aspect_ratio=" "${PROGRESSFILE}" | cut -d'=' -f2)

echo SAR $s_aspect_ratio

echo DAR $d_aspect_ratio

#
width_ratio=$(echo $d_aspect_ratio | cut -d':' -f1)
height_ratio=$(echo $d_aspect_ratio | cut -d':' -f2)

# calculate the *_REAL_* height and width
big_height=$(expr $big_width / $width_ratio \* $height_ratio)
med_height=$(expr $med_width / $width_ratio \* $height_ratio)
thumb_height=$(expr $thumb_width / $width_ratio \* $height_ratio)

# use the maxrate as the base for the bitrate calculations (Perfect Stream would have 25x this rate.)
b_maxrate=$(expr $big_width \* $big_height \* 4)
m_maxrate=$(expr $med_width \* $med_height \* 5)

# convert from bit to kb
ff_big=$(awk -v br=$b_maxrate 'BEGIN { printf "%.0f", br / 1024}')
ff_med=$(awk -v br=$m_maxrate 'BEGIN { printf "%.0f", br / 1024}')

big_maxrate=${ff_big}"k"
big_bv=$(expr $ff_big / 2)"k"
big_bufsize=$(expr $ff_big \* 3)"k"
big_minrate=$(expr $ff_big / 3)"k"
med_maxrate=${ff_med}"k"
med_bv=$(expr $ff_med / 2)"k"
med_bufsize=$(expr $ff_med \* 3)"k"
med_minrate=$(expr $ff_med / 3)"k"

#set the buffer according to height and width ()
buffbig="-qmin 2 -qmax 18 -crf 18 -b:v ${big_bv} -minrate ${big_minrate} -maxrate ${big_maxrate} -bufsize ${big_bufsize} -vf scale=${big_width}:trunc(ow/a/2)*2,hqdn3d=2:1:2"
buffmed="-qmin 2 -qmax 18 -crf 18 -b:v ${med_bv} -minrate ${med_minrate} -maxrate ${med_maxrate} -bufsize ${med_bufsize} -vf scale=${med_width}:trunc(ow/a/2)*2,hqdn3d=2:1:2"
basics="${offset} -progress ${PROGRESSFILE} -force_key_frames 00:00:00.000 -pix_fmt yuv420p "
#testing="-ss 00:00:10 -t 10"

vf_scale="${big_width}:${big_height}"
exit
# make the first needed stuff first
ffmpeg -y -i "${ACTIVEFILE}"  -loglevel error -metadata title="${title}" -metadata author="${author}"  -f image2 -ss 00:00:01 -vframes 1 -r 1 -vf "scale=${big_width}:${big_height}" -an ${tmp}/poster-720p.png

. $DIR/lib/./video2poster.sh "${tmp}/img00001.png" 2>> ${file}.detect


gm convert ${tmp}/poster-720p.png -quality 92 -resize '512x512>'  ${file}-preview.jpg  || echo "could not create preview.png"
ffmpeg -y -i "${ACTIVEFILE}" -loglevel error -metadata title="${title}" -metadata author="${author}"  -f image2 -ss 00:00:01 -vf "scale=${thumb_width}:${thumb_height}" -frames:v 1  -vsync 0 -an "${tmp}/img%05d.png"

. $DIR/lib/./pic2thumb.sh "${tmp}/img00001.png"

#gm convert ${tmp}/poster-720p.png -quality 92 ${file}-poster-720p.jpg
gm convert ${tmp}/poster-720p.png -quality 92 -resize ${med_width}x ${file}-poster-360p.jpg  || echo "could not create 360p.jpg" || echo "could not create 360p.jpg"
ffmpeg -y -i $ACTIVEFILE -loglevel error -metadata title="${title}" -metadata author="$3"  -f image2 -vf "select=gt(scene\,0.1),scale=${thumb_width}:${thumb_height}" -frames:v 20 -vsync 0 -an "${tmp}/img%05d.png" 2>> ${file}.detect


#-ordered-dither threshold,8,8,4
gm convert -delay 25 -loop 0 "${tmp}/img*.png" -depth 16 -filter lanczos -thumbnail '16384@' -gravity center -background black -extent '128x128' -depth 8 "${file}-thumb.gif"  || echo "could not create animatedthumb.gif"

ffmpeg -y -i "${ACTIVEFILE}"  -loglevel error -metadata title="${title}" -metadata author="$3"  -f mp4 -c:a libfdk_aac -b:a 128k -c:v libx264 ${basics} -vprofile main ${buffmed} -movflags faststart "${file}-360p.mp4" 2>> ${file}.detect

ffmpeg -y -i "${ACTIVEFILE}"  -loglevel error -metadata title="${title}" -metadata author="$3"  -f webm -c:a libvorbis -b:a 128k -c:v libvpx ${basics} ${buffmed} "${file}-360p.webm" 2>> ${file}.detect

ffmpeg -y -i "${ACTIVEFILE}"  -loglevel error -metadata title="${title}" -metadata author="$3"  -c:a libvorbis -b:a 128k -c:v libtheora ${basics} ${buffmed} "${file}-360p.ogg" 2>> ${file}.detect




#rm -R $tmp