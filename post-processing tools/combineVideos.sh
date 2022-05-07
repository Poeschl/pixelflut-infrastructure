#!/usr/bin/env bash
#
# This little tool combine recorded pixelflut .mks into a big standardized h265 video mp4.
# This is normally used to spread the recording on your favorite video sharing platform.
#
set -e

INPUT_FILES=( "$@" )
RESULT_FILE='combined.mp4'

if [ -z "$INPUT_FILES" ]; then
  echo 'No input files are detected.'
  echo 'Arguments like this are expected: ./combineVideos.sh PixelTest-2022-04-30_10-26.mkv PixelTest-2022-04-30_10-30.mkv'
fi

echo "Start creating video of files $@"

INPUTS=""
INPUT_VIDEO_STREAMS=""
INPUT_COUNT=0
for file in "${INPUT_FILES[@]}"; do
   INPUTS="$INPUTS -i $file"
   INPUT_VIDEO_STREAMS="$INPUT_VIDEO_STREAMS [${INPUT_COUNT}:v:0]"
   INPUT_COUNT=$((INPUT_COUNT+1))
done

set -x
ffmpeg \
  $INPUTS \
  -filter_complex "$INPUT_VIDEO_STREAMS concat=n=${INPUT_COUNT}:v=1:a=0 [combinedv]" \
  -map '[combinedv]' -vcodec hevc_nvenc -preset fast -b:v 6M -an \
  -r 30 ${RESULT_FILE}
set +x

echo "Finished creation of $RESULT_FILE"
