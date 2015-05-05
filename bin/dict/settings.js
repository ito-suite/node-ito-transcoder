module.exports = {
    thumb: {
        width: 120,
        height: 120,
        mime: "image/jpeg"
    },
    video: {
        "w_1080": [ "1080"],
        "w_720": [ "720"],
        "w_360": [ "360"],
        "w_180": [ "180"],
        "w_90": [ "90"],
        "h264": ["-c:a libfdk_aac -c:v libx264 "],
        "x264": ["-c:a libfdk_aac -c:v libx264 -profile:v DEFAULT"],
        "x264_DEFAULT": ["baseline"],
        "h265": ["-c:a libfdk_aac -c:v libx265 "],
        "webm": ["-c:a libvorbis -c:v libvpx "],
        "ogg": ["-c:a libvorbis -b:a 128k -c:v libtheora "],
        "hq": ["-crf 18 "],
        "perf": ["-tune fastdecode -tune zerolatency -profile:v baseline -crf 23 "],
        "threads": ["-threads DEFAULT "],
        "threads_DEFAULT": ["2"]
    }
};


