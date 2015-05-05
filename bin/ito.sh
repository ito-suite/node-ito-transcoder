#!/bin/bash -i

begin=$(date +%s)
date=$(date)
PWD=$(pwd)
#GET THE REAL BIN DIRECTORY TO
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
    DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
PACKAGE=$(grep 'command'  "$DIR/../package.json" | cut -d'"' -f4)
VERSION=$(grep 'version'  "$DIR/../package.json" | cut -d'"' -f4)
DESCRIPTION=$(grep 'description'  "$DIR/../package.json" | cut -d'"' -f4)
CONTACT=$(grep 'author' "$DIR/../package.json" | cut -d'"' -f4)

Error ()
{
    echo "ERROR: $1"
    exit 10
}

Cleanup ()
{
    #rm tmp files
    if [[ -d "${tmp}" ]]; then
        rm -r "${tmp}" || Error "Problem removing tmp folder"
    fi
    if [[ -f "${file}.log" ]]; then
        sed -i "s@${dir}@${holder}@g" ${file}.log
    fi
}

Register ()
{
    if [[ -f "$1" ]]; then
        # clean the file path before it is written to a public directory
        safeURI=$(echo "${1}" | sed "s@${dir}@${holder}@g")
        if [[ -f "${file}.register" ]]; then
            echo "${safeURI}" >> "${file}.register"
        else
            echo "${safeURI}" > "${file}.register"
        fi
    fi
    shift
}

getMimeType()
{
    # is xdg-mime installed?
    command -v xdg-mime >/dev/null 2>&1 || useFILE=true  # this is posix
    if test ${useFILE}; then
        # use file cuz anton
        mime=$( echo "$(file -b -k --mime-type ${ACTIVEFILE})" )
    else
        # xdg-mime does a better job than file
        mime=$( xdg-mime query filetype ${ACTIVEFILE} )
    fi

    # ply & obj workarounds - could be cleaner, but this works
    # ply mime is either text/plain or application/binary
    # in the latter case we expect an attack vector and ignore it.

    if [[ $extension == "ply" ]] && [[ $mime == "text/plain" ]]
    then

        # all ply files start with ply, so we grab the first line
        read -r firstline < $1

        # but because it may be from a mac, unix or windows system we don't know how the line ends
        # so try to cut the string at y and if the remains are pl, then win!
        # of course this is a work around, but it is fast and always right.
        firstline=$(echo $firstline | cut -d'y' -f1)
        if [[  $firstline == "pl" ]]
        then
            mime="model/fake-mime-ply"
        fi
    fi

    # security risk. we are now assuming something...
    if [[ $extension == "obj" ]] && [[ $mime == "text/plain" ]]
    then
        mime="model/fake-mime-obj"
    fi
    if [[ $extension == "mod" ]] && [[ $mime == "application/binary" ]]
    then
        mime="model/fake-mime-obj"
    fi
    if [[ $extension == "y4m" ]] && [[ $mime == "application/binary" ]]
    then
        # y4m is yuv4mpeg
        # -f yuv4mpegpipe
        mime="video/fake-y4m"
    fi

}

SetFileVars()
{
# . ./tools/./SetFileVars.sh
    if test ${ACTIVEFILE}; then
        fullfile=${ACTIVEFILE}
    else
        if test $1; then
            fullfile=${1}
            ACTIVEFILE=${1}
        else
            echo "NO FILE FOUND"
            exit 0
        fi
    fi

    # get the file up to the last dot
    file="${ACTIVEFILE%.*}"

    # get the filename without ending or folders
    base=$(basename ${ACTIVEFILE})
    base="${base%.*}"

    # get the immediately preceding directory
    count=$(echo ${ACTIVEFILE} | awk -F/ {'print NF'})
    last=$(($count -1))
    holder=$(echo ${ACTIVEFILE} | cut -d/ -f${last})
    count=null
    last=0

    # get the dirname
    dir=$(dirname ${ACTIVEFILE})

    #grab the extension
    extensionBIG=${ACTIVEFILE##*.}

    # make it lowercase
    extension=$(echo ${extensionBIG} | awk '{print tolower($0)}')

    # set our tmp directory
    tmp=$(dirname ${ACTIVEFILE})"/${base}_tmp"

    # use the '-p' flag to create only if it doesn't exist
    mkdir -p ${tmp}

    # prepare a progress filename for ffmpeg
    PROGRESSFILE="${tmp}/${base}.progress"

}

Detox()
{
    DETOX=$(detox "${fullfile}" -v | grep " -> " | cut -d'>' -f2)
    if test ${DETOX}; then
        echo "Original Filename DETOXIFIED"
        ACTIVEFILE=${DETOX}
        SetFileVars
    fi
}

__MAIN()
{
    if test ${mime} ; then
        if [[ ${detox} != "off" ]] ; then
            Detox
        fi
        if [[ ${clamav} != "off" ]] ; then
            clamscan "${fullfile}"
        fi
        echo "FILE:   ${base}.${extension}" >> ${file}.detect
        echo "MIME:   ${mime}" >> ${file}.detect
        echo "START:  ${date}" >> ${file}.detect
        echo "PRESET: ${presets}" >> ${file}.detect

        submodule=$(grep "${mime}" "$DIR/dict/mimes.json" | cut -d":" -f1 | cut -d\" -f2)
        echo "Beginning Transcoding with ${submodule} module" 2>/dev/null >> ${file}.detect

        #echo "${holder}/${base}.${extension}" >> "${file}.register"

        Register "${ACTIVEFILE}"
        if test ${submodule}
            then

                # at the moment we only accept one input
                . $DIR/converters/./${submodule}.sh

                # Get rid of stuff we don't want and hide
                ### Cleanup
            else
                Error  "Mime: ${mime} not found. File: ${ACTIVEFILE} not processed"
                exit 0
        fi
    fi
}

if test $# -gt 0; then
    while test $# -gt 0; do
        case "$1" in
            -i|--input)
                shift
                if test $# -gt 0; then
                    next=$(printf "%.1s" $1)
                    if test $next != "-"; then
                        if test -f $1; then

                            ACTIVEFILE=$1
                            getMimeType
                            SetFileVars

                        else
                            FILELIST=$1
                        fi
                    else
                        Error "Transcoding of entire filesystem not yet supported"
                    fi
                else
                    Error "No file specified"
                fi
                shift
                ;;
            -p|--preset)
                # use presets
                shift
                if test ${output}; then
                    Error "Cannot use both preset and output"
                fi
                if test $# -gt 0; then
                    next=$(printf "%.1s" $1)
                    if test ${next} != "-"; then
                        presets=${1}
                    else
                        Error "Preset flag set, but no presets given."
                    fi
                else
                    Error "Preset flag set, but no presets given."
                fi
                shift
                ;;
            -o|--output)
                shift
                if test ${presets}; then
                    Error "Cannot use both preset and output"
                fi
                if test $# -gt 0; then
                    next=$(printf "%.1s" $1)
                    if test $next != "-"; then
                        if test -f $1; then
                            output=$1
                        else
                            Error "${1} does not exist"
                        fi
                    else
                        Error "No file specified"
                    fi
                else
                    Error "No file specified"
                fi
                shift
                ;;

            -h|--help)
                echo "${PACKAGE} v${VERSION}"
                echo -e "Usage: \e[36m${PACKAGE} -f infile [OPTION]...\e[0m "
                echo "Transcode any file into web-browsable file-types with presets"
                echo "while maintaining the original file for archival purposes."
                echo ""
                echo 'Options:'
                echo '  -i, --input         path / file / url'
                echo '                      multiple assets must be called thusly'
                echo '                      -i "[asset1.jpg],[asset2.png]"'
                echo '                      only one path may be specified, and if true, this will'
                echo '                      be the target directory used for ITO output & tmp'
                echo '  -p, --preset        use comma seperated preset values to render child assets'
                echo '                      do not use preset and output at the same time.'
                echo '  -o, --output        create your own complex output types'
                echo '                      do not use preset and output at the same time.'
                echo '  -d, --detect        perform robust detection, report and exit.'
                echo '                      without any comma seperated sub-options it'
                echo '                      will attempt all methods of detection available'

                echo '      exiftool        read out all EXIF / XMP information'
                echo '      identify        get very detailed information about images with gm identify'
                echo '                      very specific information can be retrieved thusly:'
                echo -e "                      \e[36m${PACKAGE} -f whatever.gif -d identify=\"-format '|%m:%h:%w:%p'\"\e[0m"
                echo "                      and \"\|GIF:229:183:1\" will be returned to stdout"
                echo '      ffprobe         useful for getting itsoffset, SAR/DAR, codec etc.'
                echo -e "                      \e[36m${PACKAGE} -f whatever.nbm -d ffprobe=\"itsoffset,SAR,DAR\"\e[0m"
                echo "                      and those values will be returned"
                echo '      mime            use "xdg-mime query filetype" to return mime-type'
                echo '      lesspipe        quick way to gather infomation about a file / archive'
                echo '  -v, --version       show version of ITO & all compiled mime-classes'
                echo '  -t, --trust         this turns off antivirus and filename detox.'
                echo '  -h, --help          show this help'

                echo ""
                echo "Minimal use:"
                echo -e "  \e[36m${PACKAGE} -i \"pic.jpg\" \e[0m"
                echo "    By not supplying a mimetype, ${PACKAGE} assumes a local user, which will"
                echo "    invoke 'xdg-mime query filetype' to determine mimetype, 'clamAV' to detect"
                echo "    knowable viruses and 'detox' to clean up the filename. It will dump all"
                echo "    results in the folder where the input file is to be found, including logs."
                echo ""
                echo "Detect use:"
                echo -e "  \e[36m${PACKAGE} -i \"pic.gif\" -d mime,lesspipe,exiftool \e[0m"
                echo "    This feature will attempt to acquire any and all information about the file"
                echo "    in question by identifying its mime-type, lesspiping the file, and applying"
                echo "    exiftool, of course other options are available. Except for ffprobe, any"
                echo "    commands passed here will be used verbatim in the tool."
                echo ""
                echo "Server use:"
                echo -e "  \e[36m${PACKAGE} -i \"pic.gif\" -p \"thumb,preview,480x,1080x,mp4\" \e[0m"
                echo "    This supplies a file, a mime-type and a set of comma seperated child asset"
                echo "    results. Here we assume that the service caller has correctly identified the"
                echo "    mime-type with \"xdg-mime query filetype\", however in some cases \(such as .obj\)"
                echo "    further detection will be attempted."
                echo "    If the presets fail at any point, the process will be stopped."
                echo ""

                exit 0
                ;;

            -t|--trust)
                clamav="off"
                detox="off"
                shift
            ;;

            -d|--detect)
                shift
                detect=true
                if test $# -gt 0; then
                    next=$(printf "%.1s" $1)
                    if test ${next} != "-"; then
                            detectline=$1
                        shift
                    else
                        detectline="mime,exiftool,gmidentify,ffprobe,mplayer,lesspipe"
                        shift
                    fi
                else
                    detectline="mime,exiftool,gmidentify,ffprobe,mplayer,lesspipe"
                    shift
                fi
                ;;
            -v|--version)
                echo "${PACKAGE} v${VERSION}"
                echo "Maintained by: ${CONTACT}"
                echo ""
                cat "$DIR/dict/mimes.json"
                exit 0
                ;;
            *)
                echo "The flag '${1}' was not found."
                shift
            ;;
        esac
    done
else
    echo "${PACKAGE} v${VERSION}"
    echo "use --help for more information"
    exit 0
fi


# if file list gather assets into tmp
if test ${FILELIST} ; then
    count=$(echo ${FILELIST} | awk -F, {'print NF'})
    i=2
    while test $i -le $count; do
        assets[$i]=$(echo ${FILELIST} | cut -d, -f${i}) 2>/dev/null
        if [ -d "$assets[$i]" ]; then # dir
            if test ${setdir}; then
                setdir=$assets[$i]
                echo "$assets[$i] is a directory"
            else
                Error "Only one directory per ITOration"
                exit 1
            fi
        elif [ -f "$assets[$i]" ]; then # file

                echo "$assets[$i] is a file"
                fullfile="$assets[$i"
                SetFileVars
        else
            mime=$(curl -I "$1" 2>&1 | grep "Content-Type" | cut -d: -f2 | cut -d; -f1 | cut -d' ' -f2)
            if [[ $mime == "text/html" ]]; then
                echo "assets[$i]" > "original.url"
            else
                if test ${mime}; then

                    Filename=${assets[$i]##*/}
                    FileStub=${Filename%.*}
                    wget -nc "assets[$i]" -O ${assets[$i]%.*} || Error "Could not wget assets[$i]"
                fi
            fi
        fi
        i=$(expr $i + 1)
    done
else # just one file / or perhaps one url

    if test ${detect}; then
        . ./tools/./detect.sh
        rm -r ${tmp}
        exit
    fi

__MAIN



fi
exit 0