# THIS NEEDS A CLEANUP #


## Here is the upload waterfall as it stands: ##

1. checksumWorker > exists? exists : new Error ('File Exists')
2. clamWorker > err ? err : new Error ('File is Infected') && rm upload_folder+"/"+doc._id
3. mimeWorker > err ? err : new Error ('Mime not detectable')
4. qrWorker
5. lesspipeWorker > becomes ITOworker
6. update and save doc
7. notify user
8. Update SOLR
9. Reap temp files

Here is an example output line for transcoding a video into its respective parts. It may seem complex, but the need for granularity and settings makes ITO slightly different from LESSPIPE. We make use of variable nesting as in the following (default) example for complete transcoding of all assets on a First Up First Out (FUFO) basis for a video mime type:

```
#!bash
--output "video=(preview[720] -ss[00:02:03.125] output[jpg]),image=noexif src[preview] (output[jpg] (thumb[120])(poster[720])(poster[720])(poster[360])(preview[720]))(output[gif] thumbgif[120]),video=threads[4](w720 hq (x264[high] output[mp4]) (ogv output[ogg]) (webm output[webm]))(w360 perf (x264[baseline] output[mp4]))"

Presets use sequential nesting within parenthesis, where variables are passed down to children and each function is called in waterfall-type synchronous calls. Each individual setting is minimally separated with a space and everything within brackets is a substitution for the default value.

Which can be viewed in tree form:

image
    noexif
        output[jpg]
            thumb[120]
            poster[720]
            poster[360]
            preview[720]
        output[gif] thumbgif[120]
video
    threads[4]
        w720 hq
            x264[high] output[mp4]
            ogv output[ogg]
            webm output[webm]
        w360 perf
            x264[baseline] output[mp4]
            ogv output[ogg]
            webm output[webm]
    
eg video
input >
    outgest 1   = IMAGE:noexif,thumb[120],output[jpg]
    outgest 2   = IMAGE:noexif,thumbgif[120],output[jpg]
    outgest 3   = IMAGE:noexif,poster[720],output[jpg]
    outgest 4   = IMAGE:noexif,thumb[360],output[jpg]
    outgest 5   = VIDEO:w720,hq,x264[high],output[mp4]
    outgest 6   = VIDEO:w720,hq,ogv,output[ogg]
    outgest 7   = VIDEO:w720,hq,webm,output[webm]
    outgest 8   = VIDEO:w360,perf,x264[baseline],output[mp4]
    outgest 9   = VIDEO:w360,perf,ogv,output[ogg]
    outgest 10  = VIDEO:w360,perf,webm,output[webm]

todo
ITO GROUPIFY
multiple images / pdfs / texts > pdf
multiple images / videos > video
video1.edl,video2.edl,videoN.edl > video (video editor)
multiple audio files > audio
multiple texts > html

for (I.n < I.count)

I) input asset I[1...n]
T) make zwischenzeug I[0]
O) output  
            
Usage: ito.sh -f infile [OPTION]... 
Transcode any file into web-browsable file-types with presets
while maintaining the original file for archival purposes.

Options:
  -i, --input         path / file / url
                      multiple inputs are comma separated

  -p, --preset        use comma separated preset values to render child assets
                      try presets.sh -h/--help to get more information
                      do not use preset and output at the same time.

  -o, --output        create your own complex output types   
                      do not use preset and output at the same time.

  -d, --detect        perform robust detection, report to ${file}.detect and exit.
                      without any comma separated sub-options it
                      will attempt all methods of detection available
      mime            use "xdg-mime query filetype" to return mime-type
      exiftool        read out all EXIF / XMP information
      identify        get very detailed information about images with gm identify
                      very specific information can be retrieved thusly:
                      ito.sh -i whatever.gif -d identify="-format '|%m:%h:%w:%p'"
                      and "\|GIF:229:183:1" will be returned to stdout
      ffprobe         useful for getting itsoffset, SAR/DAR, codec etc.
                      ito.sh -i whatever.nbm -d ffprobe="itsoffset,SAR,DAR"
                      and those values will be returned
      mplayer         somewhat different reporting than ffprobe
      lesspipe        quick way to gather information about archives / pdfs

  -m, --mime          declare a mime-type, which will override clamAV and detox calls
                      because it assumes this has taken place server side
                 
  -v, --version       show version of ITO & all compiled mime-classes

  -t, --test          this turns off antivirus and filename detox. 

  -h, --help          show this help

Minimal use:
  ito.sh -i "pic.jpg" 
    By not supplying a mimetype, ITO assumes a local user, which will
    invoke 'xdg-mime query filetype' to determine mimetype, 'clamAV' to detect
    knowable viruses and 'detox' to clean up the filename. It will dump all
    results in the folder where the input file is to be found, including logs.

Detect use:
  ito.sh -i "video.mp4" -d mime,lesspipe,exiftool 
    This feature will attempt to acquire any and all information about the file
    in question by identifying its mime-type, lesspiping the file, and applying
    exiftool, of course other options are available. Except for ffprobe, any
    commands passed here will be used verbatim in the tool.

Server use with preset output:
  ito.sh -i "video.mp4" -m "video/mp4"
    This feature will use the default settings available to it as defined in defaults.json 

Server use with complex output:
  ito.sh -i "video.mp4" -m "video/mp4" -o "video=threads[4](w720 hq (x264[high] output[mp4]) (ogv output[ogg]) (webm output[webm]))(w360 perf (x264[baseline] output[mp4])),image=noexif (output[jpg] (thumb[120])(poster[720])(poster[360])(preview[720]))(output[gif] thumbgif[120])"
    This supplies a file, a mime-type and a set of comma separated child asset
    results. Here we assume that the service caller has correctly identified the
    mime-type with "xdg-mime query filetype", however in some cases (such as .obj)
    further detection will be attempted.
    
Multiple inputs:
  You must provide a file structured thusly:
  
  FILE
  target[pdf],height[720],width[1280]
  image1.jpg
  image2.jpg
  image3.jpg
  image4.gif[explode]
  image5.gif[first]
  EOF
  
  Where the first line is the controller with target and settings

Tools:
    detect.sh         called with the --detect flag [ also standalone ]
    getMimeType.sh    wrapper for xdg-mime [ also standalone ]
    setFileVars.sh    used to make sure the variables are set correctly in one place
    presets.sh        parses the presets from the flag according to presets.json
    settings.sh       
    ${mimeClass}.sh   the actual mime specific transcoders controlled by settings.sh

Dictionaries:
    mimes.json        contains all transcodable mime-types sorted into mime-classes
    settings.js       line-based settings  
    defaults          default handmade setting-clusters for typical workflows

Normal flow:
    ito.sh [ setFileVars.sh | getMimeType.sh ] | [ detect.sh ]
        presets.sh 
        settings.sh
            ${mimeClass}.sh

```
